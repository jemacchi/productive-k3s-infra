# Productive K3S Infra Documentation Workspace

This directory contains the MkDocs workspace for the Productive K3S Infra documentation site.

## Layout

```text
docs/
├── build.sh
├── serve.sh
├── clean.sh
├── requirements.txt
├── mkdocs.yml
└── src/
    ├── index.md
    ├── assets/
    ├── overrides/
    ├── en/
    └── es/
```

## Language policy

- English is the default documentation language
- Spanish is maintained as a mirrored tree
- every publishable page under `src/en/` should have a matching page under `src/es/`

## Local workflow

Build the site:

```bash
./docs/build.sh
make docs-build
```

Serve the site locally in the foreground:

```bash
./docs/serve.sh
make docs-serve
```

Start MkDocs in the background:

```bash
make docs-up
```

Stop the background server and clean generated artifacts:

```bash
make docs-down
```

Full cleanup of generated artifacts and the local virtual environment:

```bash
./docs/clean.sh
make docs-clean
```

## Validation

The strict site build is:

```bash
./docs/build.sh
```

## Where to review the site

The local MkDocs server publishes at:

```text
http://127.0.0.1:8000
```

In most browsers, `http://localhost:8000` should also work.
