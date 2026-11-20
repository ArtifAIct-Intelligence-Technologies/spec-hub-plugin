# Spec Hub plugin

Skills and the MCP connection that let your AI work with [Spec Hub](https://spec.artifaict.team): read the
current spec before it codes, cite rule codes, follow your organization's own rules, keep its notes on your
Local Board, and review pull requests in your name.

This plugin holds no organization data. Your organization's rules, specs and boards stay in Spec Hub and
are read through the MCP with your own sign-in and rights.

## Install

Step-by-step guides for each tool (Claude, Codex, Cursor, Kiro, Antigravity), for the terminal and the
desktop apps, are on Spec Hub: https://spec.artifaict.team/#/connect

Claude (chat, Cowork, desktop app and Claude Code, one install for all of them):

1. Open https://claude.ai/customize/plugins
2. Add marketplace: `ArtifAIct-Intelligence-Technologies/spec-hub-plugin`
3. Install **spec-hub**, then open its Connectors tab and connect Spec Hub

Claude Code from the terminal only:

```
claude plugin install spec-hub --marketplace ArtifAIct-Intelligence-Technologies/spec-hub-plugin
```

Other tools: add the MCP server `https://spec.artifaict.team/mcp` (Streamable HTTP, sign in with the browser)
and use `AGENTS.md` as the tool's instructions.

## Update

Installed from claude.ai: updates by itself. From the terminal:

```
claude plugin marketplace update spec-hub && claude plugin update spec-hub@spec-hub
```

`AGENTS.md`: download it again when https://spec.artifaict.team/kit-version.json shows a newer version.
