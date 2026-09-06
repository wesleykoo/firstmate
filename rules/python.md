# Rules: Python

## Python Environment Management

- Always use `uv` for Python package management, never conda/anaconda
- Create virtual environments with `uv venv`
- Install packages with `uv pip install` or add to `pyproject.toml` and run `uv sync`
- Use `uv run` to execute scripts within the managed environment

## Python Script Standards for Skills

All Python scripts written for skills in this project must follow CLI design:

- Use `argparse` for all inputs as `--flag` arguments
- Output structured JSON to stdout on success
- Write human-readable error messages to stderr with specific context
- Exit code 0 = success, 1 = data error, 2 = bad arguments
- Include `--help` describing inputs and output format
- Never mix debug logs with stdout JSON output
