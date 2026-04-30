import { execFile } from "child_process";
import fs from "fs";
import os from "os";
import path from "path";

import { logger } from "./util/logger.js";

function getContinueGlobalDir(): string {
  return (
    process.env.CONTINUE_GLOBAL_DIR || path.join(os.homedir(), ".continue")
  );
}

export type TriggerEventType = "session_start" | "session_end";

export async function runTriggerScript(
  eventType: TriggerEventType,
  sessionId: string,
): Promise<void> {
  try {
    const globalDir = getContinueGlobalDir();
    const scriptName =
      eventType === "session_start"
        ? "session_start_trigger"
        : "session_end_trigger";
    const triggerTsPath = path.join(globalDir, `${scriptName}.ts`);
    const triggerJsPath = path.join(globalDir, `${scriptName}.js`);

    let scriptPath: string;
    let args: string[];

    if (fs.existsSync(triggerJsPath)) {
      scriptPath = triggerJsPath;
      args = [scriptPath];
    } else if (fs.existsSync(triggerTsPath)) {
      scriptPath = triggerTsPath;
      args = ["--import", "tsx", scriptPath];
    } else {
      return;
    }

    const child = execFile(process.execPath, args, {
      cwd: globalDir,
      env: {
        ...process.env,
        CONTINUE_EVENT_TYPE: eventType,
        CONTINUE_SESSION_ID: sessionId,
      },
      timeout: 30000,
    });

    let stdout = "";
    let stderr = "";

    child.stdout?.setEncoding("utf8");
    child.stdout?.on("data", (data: string) => {
      stdout += data;
    });

    child.stderr?.setEncoding("utf8");
    child.stderr?.on("data", (data: string) => {
      stderr += data;
    });

    child.on("close", (code) => {
      if (code !== 0) {
        logger.warn(`Trigger script exited with code ${code}: ${stderr}`);
      } else if (stdout) {
        logger.debug(`Trigger script output: ${stdout}`);
      }
    });

    child.on("error", (error) => {
      logger.warn(`Failed to run trigger script: ${error.message}`);
    });
  } catch (error) {
    logger.warn(
      `Error running trigger script: ${
        error instanceof Error ? error.message : String(error)
      }`,
    );
  }
}
