export const capitalizeFirstLetter = (val: string) => {
  if (val.length === 0) {
    return "";
  }
  return val[0].toUpperCase() + val.slice(1);
};

/**
 * 【Qwen3.5 中英文空格修复】移除中文与英文/数字之间的空格
 * 解决模型在 CJK↔Latin 之间自动加空格的问题（盘古之白）
 */
export function cleanCJKSpaces(value: string): string {
  return value
    .replace(/([\u4e00-\u9fff])\s+([A-Za-z0-9])/g, "$1$2")
    .replace(/([A-Za-z0-9])\s+([\u4e00-\u9fff])/g, "$1$2");
}

/**
 * 递归清洗对象中的所有字符串参数，移除中英文之间的空格
 */
export function cleanArgs(args: any): any {
  if (args === null || args === undefined) {
    return args;
  }
  if (typeof args === "string") {
    return cleanCJKSpaces(args);
  }
  if (Array.isArray(args)) {
    return args.map(cleanArgs);
  }
  if (typeof args === "object") {
    const cleaned: Record<string, any> = {};
    for (const [key, value] of Object.entries(args)) {
      cleaned[key] = cleanArgs(value);
    }
    return cleaned;
  }
  return args;
}

export function replaceEscapedCharacters(str: string): string {
  return str.replaceAll(/\\(n|t|r|\\|"|')/g, (match, p1) => {
    switch (p1) {
      case "n":
        return "\n";
      case "t":
        return "\t";
      case "r":
        return "\r";
      case "\\":
        return "\\";
      case '"':
        return '"';
      case "'":
        return "'";
      default:
        return match; // NOTE: Handle unexpected escapes better than this.
    }
  });
}

export function escapeForSVG(text: string): string {
  return text
    .replace(/&/g, "&amp;") // must be first
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&apos;")
    .replace(/\n/g, "\\n") // newlines
    .replace(/\t/g, "\\t") // tabs
    .replace(/\r/g, "\\r"); // carriage returns
}

export function kebabOfStr(str: string): string {
  return str
    .replace(/([a-z0-9])([A-Z])/g, "$1-$2") // handle camelCase, PascalCase, and numbers followed by uppercase
    .replace(/[\s_]+/g, "-") // replace spaces and underscores with hyphens
    .toLowerCase();
}

export function kebabOfThemeStr(str: string): string {
  return str
    .toLowerCase()
    .replace(/[\s_]+/g, "-") // replace spaces and underscores with hyphens
    .replace(/\(|\)/g, ""); // remove parentheses
}
