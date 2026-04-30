import * as fs from "node:fs";
import { IdeSettings } from "..";
import {
  getLocalEnvironmentDotFilePath,
  getStagingEnvironmentDotFilePath,
} from "../util/paths";
import { AuthType, ControlPlaneEnv, HubEnv, KeycloakEnv } from "./AuthTypes";
import { getLicenseKeyData } from "./mdm/mdm";

export const EXTENSION_NAME = "continue";

const WORKOS_CLIENT_ID_PRODUCTION = "client_01J0FW6XN8N2XJAECF7NE0Y65J";
const WORKOS_CLIENT_ID_STAGING = "client_01J0FW6XCPMJMQ3CG51RB4HBZQ";

const PRODUCTION_HUB_ENV: ControlPlaneEnv = {
  DEFAULT_CONTROL_PLANE_PROXY_URL: "https://api.continue.dev/",
  CONTROL_PLANE_URL: "https://api.continue.dev/",
  AUTH_TYPE: AuthType.WorkOsProd,
  WORKOS_CLIENT_ID: WORKOS_CLIENT_ID_PRODUCTION,
  APP_URL: "https://continue.dev/",
};

const STAGING_ENV: ControlPlaneEnv = {
  DEFAULT_CONTROL_PLANE_PROXY_URL: "https://api.continue-stage.tools/",
  CONTROL_PLANE_URL: "https://api.continue-stage.tools/",
  AUTH_TYPE: AuthType.WorkOsStaging,
  WORKOS_CLIENT_ID: WORKOS_CLIENT_ID_STAGING,
  APP_URL: "https://hub.continue-stage.tools/",
};

const TEST_ENV: ControlPlaneEnv = {
  DEFAULT_CONTROL_PLANE_PROXY_URL: "https://api-test.continue.dev/",
  CONTROL_PLANE_URL: "https://api-test.continue.dev/",
  AUTH_TYPE: AuthType.WorkOsStaging,
  WORKOS_CLIENT_ID: WORKOS_CLIENT_ID_STAGING,
  APP_URL: "https://app-test.continue.dev/",
};

const LOCAL_ENV: ControlPlaneEnv = {
  DEFAULT_CONTROL_PLANE_PROXY_URL: "http://localhost:3001/",
  CONTROL_PLANE_URL: "http://localhost:3001/",
  AUTH_TYPE: AuthType.WorkOsStaging,
  WORKOS_CLIENT_ID: WORKOS_CLIENT_ID_STAGING,
  APP_URL: "http://localhost:3000/",
};

function getWorkOsEnv(): HubEnv | null {
  const { WORKOS_CLIENT_ID, WORKOS_URL, CONTROL_PLANE_URL, APP_URL } =
    process.env;

  if (!WORKOS_CLIENT_ID) {
    return null;
  }

  return {
    DEFAULT_CONTROL_PLANE_PROXY_URL:
      CONTROL_PLANE_URL || "https://api.continue.dev/",
    CONTROL_PLANE_URL: CONTROL_PLANE_URL || "https://api.continue.dev/",
    AUTH_TYPE: WORKOS_URL ? AuthType.WorkOsStaging : AuthType.WorkOsProd,
    WORKOS_CLIENT_ID,
    WORKOS_URL: WORKOS_URL || undefined,
    APP_URL: APP_URL || "https://continue.dev/",
  };
}

function getKeycloakEnv(): KeycloakEnv | null {
  const {
    KEYCLOAK_CLIENT_ID,
    KEYCLOAK_CLIENT_SECRET,
    KEYCLOAK_REALM,
    KEYCLOAK_URL,
    CONTROL_PLANE_URL,
    APP_URL,
  } = process.env;

  if (!KEYCLOAK_CLIENT_ID || !KEYCLOAK_URL) {
    return null;
  }

  return {
    DEFAULT_CONTROL_PLANE_PROXY_URL:
      CONTROL_PLANE_URL || "https://api.continue.dev/",
    CONTROL_PLANE_URL: CONTROL_PLANE_URL || "https://api.continue.dev/",
    AUTH_TYPE: AuthType.Keycloak,
    KEYCLOAK_CLIENT_ID,
    KEYCLOAK_CLIENT_SECRET: KEYCLOAK_CLIENT_SECRET || "",
    KEYCLOAK_REALM: KEYCLOAK_REALM || "master",
    KEYCLOAK_URL,
    APP_URL: APP_URL || "https://continue.dev/",
  };
}

export async function enableHubContinueDev() {
  return true;
}

export async function getControlPlaneEnv(
  ideSettingsPromise: Promise<IdeSettings>,
): Promise<ControlPlaneEnv> {
  const ideSettings = await ideSettingsPromise;
  return getControlPlaneEnvSync(ideSettings.continueTestEnvironment);
}

export function getControlPlaneEnvSync(
  ideTestEnvironment: IdeSettings["continueTestEnvironment"],
): ControlPlaneEnv {
  // MDM override
  const licenseKeyData = getLicenseKeyData();
  if (licenseKeyData?.unsignedData?.apiUrl) {
    const { apiUrl } = licenseKeyData.unsignedData;
    return {
      AUTH_TYPE: AuthType.OnPrem,
      DEFAULT_CONTROL_PLANE_PROXY_URL: apiUrl,
      CONTROL_PLANE_URL: apiUrl,
      APP_URL: "https://continue.dev/",
    };
  }

  const workosEnv = getWorkOsEnv();
  if (workosEnv) {
    return workosEnv;
  }

  const keycloakEnv = getKeycloakEnv();
  if (keycloakEnv) {
    return keycloakEnv;
  }

  // Note .local overrides .staging
  if (fs.existsSync(getLocalEnvironmentDotFilePath())) {
    return LOCAL_ENV;
  }

  if (fs.existsSync(getStagingEnvironmentDotFilePath())) {
    return STAGING_ENV;
  }

  const env =
    ideTestEnvironment === "production"
      ? "hub"
      : ideTestEnvironment === "staging"
        ? "staging"
        : ideTestEnvironment === "local"
          ? "local"
          : process.env.CONTROL_PLANE_ENV;

  return env === "local"
    ? LOCAL_ENV
    : env === "staging"
      ? STAGING_ENV
      : env === "test"
        ? TEST_ENV
        : PRODUCTION_HUB_ENV;
}

export async function useHub(
  ideSettingsPromise: Promise<IdeSettings>,
): Promise<boolean> {
  const ideSettings = await ideSettingsPromise;
  return ideSettings.continueTestEnvironment !== "none";
}
