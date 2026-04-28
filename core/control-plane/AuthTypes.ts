export interface HubSessionInfo {
  AUTH_TYPE: AuthType.WorkOsProd | AuthType.WorkOsStaging;
  accessToken: string;
  account: {
    label: string;
    id: string;
  };
}

export interface KeycloakSessionInfo {
  AUTH_TYPE: AuthType.Keycloak;
  accessToken: string;
  refreshToken: string;
  expiresAt: number;
  account: {
    label: string;
    id: string;
  };
}

export interface OnPremSessionInfo {
  AUTH_TYPE: AuthType.OnPrem;
}

export type ControlPlaneSessionInfo =
  | HubSessionInfo
  | KeycloakSessionInfo
  | OnPremSessionInfo;

export function isOnPremSession(
  sessionInfo: ControlPlaneSessionInfo | undefined,
): sessionInfo is OnPremSessionInfo {
  return sessionInfo !== undefined && sessionInfo.AUTH_TYPE === AuthType.OnPrem;
}

export function isKeycloakSession(
  sessionInfo: ControlPlaneSessionInfo | undefined,
): sessionInfo is KeycloakSessionInfo {
  return (
    sessionInfo !== undefined && sessionInfo.AUTH_TYPE === AuthType.Keycloak
  );
}

export enum AuthType {
  WorkOsProd = "continue",
  WorkOsStaging = "continue-staging",
  Keycloak = "keycloak",
  OnPrem = "on-prem",
}

export interface HubEnv {
  DEFAULT_CONTROL_PLANE_PROXY_URL: string;
  CONTROL_PLANE_URL: string;
  AUTH_TYPE: AuthType.WorkOsProd | AuthType.WorkOsStaging;
  WORKOS_CLIENT_ID: string;
  WORKOS_URL?: string;
  APP_URL: string;
}

export interface KeycloakEnv {
  DEFAULT_CONTROL_PLANE_PROXY_URL: string;
  CONTROL_PLANE_URL: string;
  AUTH_TYPE: AuthType.Keycloak;
  KEYCLOAK_CLIENT_ID: string;
  KEYCLOAK_CLIENT_SECRET: string;
  KEYCLOAK_REALM: string;
  KEYCLOAK_URL: string;
  APP_URL: string;
}

export interface OnPremEnv {
  AUTH_TYPE: AuthType.OnPrem;
  DEFAULT_CONTROL_PLANE_PROXY_URL: string;
  CONTROL_PLANE_URL: string;
  APP_URL: string;
}

export type ControlPlaneEnv = HubEnv | KeycloakEnv | OnPremEnv;

export function isHubEnv(env: ControlPlaneEnv): env is HubEnv {
  return (
    "AUTH_TYPE" in env &&
    (env.AUTH_TYPE === AuthType.WorkOsProd ||
      env.AUTH_TYPE === AuthType.WorkOsStaging) &&
    "WORKOS_CLIENT_ID" in env
  );
}

export function isKeycloakEnv(env: ControlPlaneEnv): env is KeycloakEnv {
  return (
    "AUTH_TYPE" in env &&
    env.AUTH_TYPE === AuthType.Keycloak &&
    "KEYCLOAK_CLIENT_ID" in env
  );
}
