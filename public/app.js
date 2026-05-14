const state = {
  targetDir: document.querySelector("#targetDir").value,
  activeFile: "",
  files: [],
};

const elements = {
  initForm: document.querySelector("#initForm"),
  refreshButton: document.querySelector("#refreshButton"),
  doctorButton: document.querySelector("#doctorButton"),
  doctorResult: document.querySelector("#doctorResult"),
  fileList: document.querySelector("#fileList"),
  editor: document.querySelector("#editor"),
  saveButton: document.querySelector("#saveButton"),
  activeFileTitle: document.querySelector("#activeFileTitle"),
  featureForm: document.querySelector("#featureForm"),
  decisionForm: document.querySelector("#decisionForm"),
  contextForm: document.querySelector("#contextForm"),
  contextOutput: document.querySelector("#contextOutput"),
  statusDot: document.querySelector("#statusDot"),
  statusText: document.querySelector("#statusText"),
};

elements.initForm.addEventListener("submit", async (event) => {
  event.preventDefault();
  const form = new FormData(elements.initForm);
  state.targetDir = form.get("targetDir");

  await run("Creating project", async () => {
    await api("/api/init", {
      method: "POST",
      body: {
        targetDir: state.targetDir,
        projectName: form.get("projectName"),
        projectType: form.get("projectType"),
        framework: form.get("framework"),
        aiTool: form.get("aiTool"),
        mode: form.get("mode"),
      },
    });
    await refreshState();
  });
});

elements.refreshButton.addEventListener("click", async () => {
  state.targetDir = document.querySelector("#targetDir").value;
  await run("Opening folder", refreshState);
});

elements.doctorButton.addEventListener("click", async () => {
  await run("Checking project", refreshState);
});

elements.saveButton.addEventListener("click", async () => {
  if (!state.activeFile) {
    setStatus("Choose a file first", "error");
    return;
  }

  await run("Saving file", async () => {
    await api("/api/file", {
      method: "PUT",
      body: {
        targetDir: state.targetDir,
        file: state.activeFile,
        content: elements.editor.value,
      },
    });
  });
});

elements.featureForm.addEventListener("submit", async (event) => {
  event.preventDefault();
  const form = new FormData(elements.featureForm);

  await run("Adding feature", async () => {
    const result = await api("/api/feature", {
      method: "POST",
      body: {
        targetDir: state.targetDir,
        name: form.get("name"),
        problem: form.get("problem"),
        goal: form.get("goal"),
      },
    });
    await refreshState();
    await openFile(result.result.file);
  });
});

elements.decisionForm.addEventListener("submit", async (event) => {
  event.preventDefault();
  const form = new FormData(elements.decisionForm);

  await run("Adding decision", async () => {
    const result = await api("/api/decision", {
      method: "POST",
      body: {
        targetDir: state.targetDir,
        title: form.get("title"),
        status: form.get("status"),
        context: form.get("context"),
        decision: form.get("decision"),
      },
    });
    await refreshState();
    await openFile(result.result.file);
  });
});

elements.contextForm.addEventListener("submit", async (event) => {
  event.preventDefault();
  const form = new FormData(elements.contextForm);

  await run("Building context", async () => {
    const result = await api("/api/context", {
      method: "POST",
      body: {
        targetDir: state.targetDir,
        topic: form.get("topic"),
      },
    });
    elements.contextOutput.textContent = result.output;
  });
});

await refreshState();

async function refreshState() {
  const target = encodeURIComponent(state.targetDir);
  const result = await api(`/api/state?target=${target}`);
  state.files = result.files;
  renderDoctor(result.doctor);
  renderFiles();
}

async function openFile(file) {
  const target = encodeURIComponent(state.targetDir);
  const selected = encodeURIComponent(file);
  const result = await api(`/api/file?target=${target}&file=${selected}`);

  state.activeFile = file;
  elements.editor.value = result.content;
  elements.activeFileTitle.textContent = file;
  renderFiles();
}

function renderDoctor(doctor) {
  elements.doctorResult.className = `doctor ${doctor.ok ? "ok" : "error"}`;
  elements.doctorResult.textContent = doctor.ok
    ? "Project structure looks complete."
    : `Missing ${doctor.missing.length} required file(s): ${doctor.missing.slice(0, 3).join(", ")}`;
}

function renderFiles() {
  elements.fileList.replaceChildren();

  if (state.files.length === 0) {
    const empty = document.createElement("p");
    empty.className = "doctor";
    empty.textContent = "No editable files found yet. Create a project to begin.";
    elements.fileList.append(empty);
    return;
  }

  for (const file of state.files) {
    const button = document.createElement("button");
    button.type = "button";
    button.className = `file-button${file === state.activeFile ? " active" : ""}`;
    button.textContent = file;
    button.addEventListener("click", () => {
      run("Opening file", () => openFile(file));
    });
    elements.fileList.append(button);
  }
}

async function api(path, options = {}) {
  const response = await fetch(path, {
    method: options.method ?? "GET",
    headers: options.body ? { "content-type": "application/json" } : undefined,
    body: options.body ? JSON.stringify(options.body) : undefined,
  });
  const payload = await response.json();

  if (!response.ok || payload.ok === false) {
    throw new Error(payload.error ?? "Request failed");
  }

  return payload;
}

async function run(label, task) {
  setStatus(label, "busy");

  try {
    const result = await task();
    setStatus("Ready", "ok");
    return result;
  } catch (error) {
    setStatus(error.message, "error");
    throw error;
  }
}

function setStatus(message, stateName) {
  elements.statusText.textContent = message;
  elements.statusDot.className = `status-dot ${stateName === "ok" ? "" : stateName}`;
}
