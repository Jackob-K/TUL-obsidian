const { FuzzySuggestModal, Notice, Plugin, TFile, TFolder } = require("obsidian");
const { spawn } = require("child_process");
const path = require("path");

const SUBJECT_PATTERN = /^\d{2}_.+$/;

class SubjectSuggestModal extends FuzzySuggestModal {
  constructor(app, subjects, onChoose) {
    super(app);
    this.subjects = subjects;
    this.onChoose = onChoose;
    this.setPlaceholder("Hledat předmět...");
    this.setInstructions([
      { command: "↑↓", purpose: "pohyb" },
      { command: "↵", purpose: "vybrat" },
    ]);
    this.modalEl.addClass("tul-pdf-subject-modal");
  }

  getItems() {
    return this.subjects;
  }

  getItemText(subject) {
    return subject.name;
  }

  onChooseItem(subject) {
    this.onChoose(subject);
  }
}

class ExportTargetSuggestModal extends FuzzySuggestModal {
  constructor(app, subject, folders, onChoose) {
    super(app);
    this.items = [
      { type: "root", label: "Exportovat poznámky v kořeni předmětu" },
      ...folders.map((folder) => ({ type: "folder", folder })),
    ];
    this.onChoose = onChoose;
    this.setPlaceholder(`Vyberte rozsah exportu: ${subject.name}`);
    this.setInstructions([
      { command: "↑↓", purpose: "pohyb" },
      { command: "↵", purpose: "vybrat" },
    ]);
    this.modalEl.addClass("tul-pdf-subject-modal");
  }

  getItems() {
    return this.items;
  }

  getItemText(item) {
    return item.type === "root" ? item.label : item.folder.name;
  }

  onChooseItem(item) {
    this.onChoose(item);
  }
}

module.exports = class TulPdfExportPlugin extends Plugin {
  onload() {
    this.registerObsidianProtocolHandler("tul-pdf-export", () => {
      this.openSubjectPicker();
    });
  }

  openSubjectPicker() {
    const root = this.app.vault.getRoot();
    const subjects = root.children
      .filter(
        (entry) =>
          entry instanceof TFolder &&
          SUBJECT_PATTERN.test(entry.name) &&
          entry.children.some(
            (child) => child instanceof TFile && child.extension.toLowerCase() === "md",
          ),
      )
      .sort((left, right) =>
        left.name.localeCompare(right.name, "cs", { numeric: true, sensitivity: "base" }),
      );

    if (subjects.length === 0) {
      new Notice("V kořeni vaultu není žádný předmět s Markdown poznámkou.");
      return;
    }

    new SubjectSuggestModal(this.app, subjects, (subject) => this.openExportPicker(subject)).open();
  }

  availableSubfolders(subject) {
    return subject.children
      .filter(
        (entry) =>
          entry instanceof TFolder &&
          entry.children.some(
            (child) => child instanceof TFile && child.extension.toLowerCase() === "md",
          ),
      )
      .sort((left, right) =>
        left.name.localeCompare(right.name, "cs", { numeric: true, sensitivity: "base" }),
      );
  }

  openExportPicker(subject) {
    const folders = this.availableSubfolders(subject);
    new ExportTargetSuggestModal(this.app, subject, folders, (target) => {
      if (target.type === "root") {
        this.exportSubject(subject);
      } else {
        this.exportSubject(subject, target.folder);
      }
    }).open();
  }

  exportSubject(subject, folder = null) {
    const vaultPath = this.app.vault.adapter.getBasePath();
    const launcher = path.join(vaultPath, "_shared", "tools", "build_notes.py");
    const env = { ...process.env };
    env.PATH = [
      "/usr/local/bin",
      "/opt/homebrew/bin",
      "/Library/Frameworks/Python.framework/Versions/3.12/bin",
      "/Library/TeX/texbin",
      env.PATH || "",
    ].join(path.delimiter);
    env.PYTHONDONTWRITEBYTECODE = "1";

    const args = [launcher, "--vault", vaultPath, subject.name];
    if (folder) args.push("--folder", folder.name);
    const child = spawn("python3", args, {
      cwd: vaultPath,
      env,
    });
    let stdout = "";
    let stderr = "";
    let spawnError = null;

    child.stdout.setEncoding("utf8").on("data", (chunk) => (stdout += chunk));
    child.stderr.setEncoding("utf8").on("data", (chunk) => (stderr += chunk));
    child.on("error", (error) => {
      spawnError = error;
      new Notice(`Export se nepodařilo spustit: ${error.message}`, 10000);
    });
    child.on("close", (code) => {
      if (spawnError) return;
      if (code === 0) {
        const message = stdout.trim().split("\n").pop() || `Hotovo: ${subject.name}`;
        new Notice(message, 10000);
      } else {
        new Notice(stderr.trim() || `Export skončil s chybou (${code}).`, 10000);
      }
    });
  }
};
