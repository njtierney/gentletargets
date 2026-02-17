# Schedule

## Why Pipelines?

- Where do I start? What do I run first?
- Common problems with pipelines/workflows
- Intro to {targets}
- Concepts in {targets}: functions, targets, graphs/networks
- Where we are going

## Starting with function: writing out a workflow

- Defining out functions as the unit of understanding
- Ideal properties of functions
- Properties to avoid in functions
- Writing out a workflow with functions
- Using {fnmate} to accelerate function creation

## Debugging functions

- brower()
- debug() and debugonce()
- options(recover)

## Getting started with {targets}

- Using {tflow} to set up a targets project
  - Unpacking folder structure, `_targets.R` file
  - Using functions for pipeline steps
  - Using `tar_assign()`
- Your first pipeline
- Modifying and rebuilding: understanding what changes

## Deeper workflow with {targets}

- Data read in with `tar_read()`
- Rendering reports with `tar_quarto()`
- Using keyboard shortcuts to load, inspect
- Using `tar_workspaces()` to debug issues
- Common problems when writing pipelines

## Advanced Targets Features

- Using {crew} to paralellise workflow
- Branching 
- Using targets with HPC

## Introduction to Geospatial Data

- Spatial data challenges
- Introduction to {terra} and {sf}

## Geospatial Pipelines with {geotargets}

- Why {geotargets}?
- `tar_terra_rast()`, `tar_terra_vect()`, etc
- Building a geospatial pipeline

## Production Workflows and Best Practices

- Organising large projects
- Convert your own work into a pipeline
- Feedback on your pipeline
- Resources and next steps
- Open Q&A
