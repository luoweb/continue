/**
 * This is the entry point for the extension.
 */

import { setupCa } from "core/util/ca";
import { extractMinimalStackTraceInfo } from "core/util/extractMinimalStackTraceInfo";
import { Telemetry } from "core/util/posthog";
import * as vscode from "vscode";

import { SentryLogger } from "core/util/sentry/SentryLogger";
import { getExtensionVersion } from "./util/util";
export { default as buildTimestamp } from "./.buildTimestamp";

if (!globalThis.Headers) {
  const HeadersClass = class {
    private _headers: Map<string, string>;

    constructor(init?: HeadersInit) {
      this._headers = new Map();
      if (init) {
        if (init instanceof Headers) {
          init.forEach((value, key) => {
            this._headers.set(key.toLowerCase(), value);
          });
        } else if (Array.isArray(init)) {
          for (const [key, value] of init) {
            this._headers.set(key.toLowerCase(), value);
          }
        } else {
          for (const key in init as Record<string, string>) {
            if (Object.prototype.hasOwnProperty.call(init, key)) {
              this._headers.set(
                key.toLowerCase(),
                (init as Record<string, string>)[key],
              );
            }
          }
        }
      }
    }

    append(name: string, value: string): void {
      const key = name.toLowerCase();
      const existing = this._headers.get(key);
      if (existing) {
        this._headers.set(key, `${existing}, ${value}`);
      } else {
        this._headers.set(key, value);
      }
    }

    delete(name: string): void {
      this._headers.delete(name.toLowerCase());
    }

    get(name: string): string | null {
      return this._headers.get(name.toLowerCase()) || null;
    }

    has(name: string): boolean {
      return this._headers.has(name.toLowerCase());
    }

    set(name: string, value: string): void {
      this._headers.set(name.toLowerCase(), value);
    }

    forEach(
      callbackfn: (value: string, key: string, parent: any) => void,
      thisArg?: any,
    ): void {
      for (const [key, value] of this._headers) {
        callbackfn.call(thisArg, value, key, this);
      }
    }

    *keys(): IterableIterator<string> {
      yield* this._headers.keys();
    }

    *values(): IterableIterator<string> {
      yield* this._headers.values();
    }

    *entries(): IterableIterator<[string, string]> {
      yield* this._headers.entries();
    }

    [Symbol.iterator](): IterableIterator<[string, string]> {
      return this.entries();
    }

    get [Symbol.toStringTag](): string {
      return "Headers";
    }
  };
  globalThis.Headers = HeadersClass as any;
}

if (!globalThis.FormData) {
  const FormDataClass = class {
    private _data: Array<{
      name: string;
      value: string | Blob;
      filename?: string;
    }>;

    constructor() {
      this._data = [];
    }

    append(name: string, value: string | Blob, filename?: string): void {
      this._data.push({ name, value, filename });
    }

    delete(name: string): void {
      this._data = this._data.filter((item) => item.name !== name);
    }

    get(name: string): string | Blob | null {
      const item = this._data.find((item) => item.name === name);
      return item ? item.value : null;
    }

    getAll(name: string): Array<string | Blob> {
      return this._data
        .filter((item) => item.name === name)
        .map((item) => item.value);
    }

    has(name: string): boolean {
      return this._data.some((item) => item.name === name);
    }

    set(name: string, value: string | Blob, filename?: string): void {
      this.delete(name);
      this.append(name, value, filename);
    }

    forEach(
      callbackfn: (value: string | Blob, key: string, parent: any) => void,
      thisArg?: any,
    ): void {
      for (const item of this._data) {
        callbackfn.call(thisArg, item.value, item.name, this);
      }
    }

    *keys(): IterableIterator<string> {
      for (const item of this._data) {
        yield item.name;
      }
    }

    *values(): IterableIterator<string | Blob> {
      for (const item of this._data) {
        yield item.value;
      }
    }

    *entries(): IterableIterator<[string, string | Blob]> {
      for (const item of this._data) {
        yield [item.name, item.value];
      }
    }

    [Symbol.iterator](): IterableIterator<[string, string | Blob]> {
      return this.entries();
    }

    get [Symbol.toStringTag](): string {
      return "FormData";
    }
  };
  globalThis.FormData = FormDataClass as any;
}

if (!globalThis.Response) {
  const ResponseClass = class {
    readonly headers: any;
    readonly ok: boolean;
    readonly status: number;
    readonly statusText: string;
    readonly type: string;
    readonly url: string;
    readonly body: any;
    private _body: string | null;
    private _bodyUsed: boolean;

    constructor(body?: any, init?: any) {
      this._body = body instanceof Blob ? "" : body?.toString() || null;
      this._bodyUsed = false;
      this.headers = new (globalThis.Headers as any)(init?.headers);
      this.status = init?.status ?? 200;
      this.statusText = init?.statusText ?? "";
      this.ok = this.status >= 200 && this.status < 300;
      this.type = "default";
      this.url = "";
      this.body = null;
    }

    async text(): Promise<string> {
      this._bodyUsed = true;
      return this._body ?? "";
    }

    async json(): Promise<any> {
      this._bodyUsed = true;
      return JSON.parse(this._body ?? "null");
    }

    async blob(): Promise<Blob> {
      this._bodyUsed = true;
      return new Blob([this._body ?? ""]);
    }

    async formData(): Promise<any> {
      this._bodyUsed = true;
      return new (globalThis.FormData as any)();
    }

    async arrayBuffer(): Promise<ArrayBuffer> {
      this._bodyUsed = true;
      const text = this._body ?? "";
      const encoder = new TextEncoder();
      return encoder.encode(text).buffer;
    }

    get bodyUsed(): boolean {
      return this._bodyUsed;
    }

    static error(): any {
      return new ResponseClass(null, { status: 0, statusText: "" });
    }

    static redirect(url: string, status: number = 302): any {
      return new ResponseClass(null, { status, headers: { Location: url } });
    }

    static json(data: any, init?: any): any {
      return new ResponseClass(JSON.stringify(data), {
        ...init,
        headers: { "Content-Type": "application/json", ...init?.headers },
      });
    }

    get [Symbol.toStringTag](): string {
      return "Response";
    }
  };
  globalThis.Response = ResponseClass as any;
}

if (!globalThis.Request) {
  const RequestClass = class {
    readonly headers: any;
    readonly method: string;
    readonly url: string;
    readonly body: any;
    private _bodyUsed: boolean;
    _bodyText: string | null;

    constructor(input: any, init?: any) {
      this.url = typeof input === "string" ? input : input.url;
      const inputAsAny = input as any;
      this.method = init?.method?.toUpperCase() || inputAsAny?.method || "GET";
      this.headers = new (globalThis.Headers as any)(
        init?.headers || inputAsAny?.headers,
      );

      if (init?.body) {
        this._bodyText =
          init.body instanceof Blob ? "" : init.body?.toString() || null;
      } else if (inputAsAny?._bodyText) {
        this._bodyText = inputAsAny._bodyText;
      } else {
        this._bodyText = null;
      }

      this.body = null;
      this._bodyUsed = false;
    }

    get bodyUsed(): boolean {
      return this._bodyUsed;
    }

    async text(): Promise<string> {
      this._bodyUsed = true;
      return this._bodyText ?? "";
    }

    async json(): Promise<any> {
      this._bodyUsed = true;
      return JSON.parse(this._bodyText ?? "null");
    }

    async blob(): Promise<Blob> {
      this._bodyUsed = true;
      return new Blob([this._bodyText ?? ""]);
    }

    async formData(): Promise<any> {
      this._bodyUsed = true;
      return new (globalThis.FormData as any)();
    }

    async arrayBuffer(): Promise<ArrayBuffer> {
      this._bodyUsed = true;
      const text = this._bodyText ?? "";
      const encoder = new TextEncoder();
      return encoder.encode(text).buffer;
    }

    get [Symbol.toStringTag](): string {
      return "Request";
    }
  };
  globalThis.Request = RequestClass as any;
}

async function dynamicImportAndActivate(context: vscode.ExtensionContext) {
  await setupCa();
  const { activateExtension } = await import("./activation/activate");
  return await activateExtension(context);
}

export function activate(context: vscode.ExtensionContext) {
  return dynamicImportAndActivate(context).catch((e) => {
    console.log("Error activating extension: ", e);
    Telemetry.capture(
      "vscode_extension_activation_error",
      {
        stack: extractMinimalStackTraceInfo(e.stack),
        message: e.message,
      },
      false,
      true,
    );
    vscode.window
      .showWarningMessage(
        "Error activating the Continue extension.",
        "View Logs",
        "Retry",
      )
      .then((selection) => {
        if (selection === "View Logs") {
          vscode.commands.executeCommand("continue.viewLogs");
        } else if (selection === "Retry") {
          // Reload VS Code window
          vscode.commands.executeCommand("workbench.action.reloadWindow");
        }
      });
  });
}

export function deactivate() {
  void Telemetry.capture(
    "deactivate",
    {
      extensionVersion: getExtensionVersion(),
    },
    true,
  );

  Telemetry.shutdownPosthogClient();
  SentryLogger.shutdownSentryClient();
}
