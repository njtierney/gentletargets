# Schedule

Eight chapters, ninety minutes each. The course is exercise heavy, so most of that time is yours rather than mine.

## 1. Why pipelines?

*90 minutes*

- Where do I start? What do I run first?
- Working with occurrence records: reading and cleaning
- What happens when more data arrives
- Why a document that writes files cannot be trusted
- Common problems with pipelines and workflows, and the ways people lay an analysis out
- Concepts in {targets}: functions, results worth keeping, graphs and networks
- Where we are going

## 2. Starting with functions: writing out a workflow

*90 minutes*

- Writing out a workflow with functions, before any of them exist
- Defining functions as the unit of understanding
- Ideal properties of functions
- Properties to avoid in functions
- Using {fnmate} to accelerate function creation

## 3. Debugging functions

*90 minutes*

- `browser()`
- `debug()` and `debugonce()`
- `options(recover)`

## 4. Getting started with {targets}

*90 minutes*

- Using {tflow} to set up a targets project
  - Unpacking folder structure, `_targets.R` file
  - Using functions for pipeline steps
  - Using `tar_assign()`
- Your first pipeline
- Modifying and rebuilding: understanding what changes

## 5. Deeper workflow with {targets}

*90 minutes*

- Data read in with `tar_read()`
- Seeing the dependency graph with `tar_visnetwork()`
- Predicting what will rebuild, then checking with `tar_outdated()`
- Rendering reports with `tar_quarto()`
- Using keyboard shortcuts to load, inspect
- Using `tar_workspaces()` to debug issues
- Common problems when writing pipelines

## 6. Branching and {crew}

*90 minutes*

- Branching over many of something
- Using {crew} to parallelise a workflow

## 7. Geospatial pipelines with {geotargets}

*90 minutes*

- Spatial data challenges
- Introduction to {terra} and {sf}
- Why {geotargets}?
- `tar_terra_rast()`, `tar_terra_vect()`, and friends
- Building a geospatial pipeline

## 8. Production workflows and best practices

*90 minutes*

- Organising large projects
- Convert your own work into a pipeline
- Feedback on your pipeline
- Resources and next steps
- Open Q&A

## Appendix A: Running targets on an HPC

Not taught, because there is no cluster in the room.

- `crew.cluster::crew_controller_slurm()`
- Controller groups: heavy targets to the cluster, light ones stay local
- Why workers do not source `_targets.R`, and what that breaks

## Appendix B: Cloud storage and cloud workers

Also not taught, for the same reason.

- Keeping the targets store in S3 with `repository = "aws"` and `tar_resources_aws()`
- Which file targets you still want kept local, and why
- `crew.aws.batch` for workers rather than storage
