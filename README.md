# Introduction to `targets` and `geotargets`


<!-- README.md is generated from README.qmd. Please edit that file -->

<!-- badges: start -->

<!-- badges: end -->

<https://gentle-targets.njtierney.com>

**Prerequisites**

- Experience writing basic R scripts
- Familiarity with writing functions in R
- Experience with spatial data packages (terra, sf) helpful but not required
- Experience in writing your own data analysis

**Learning outcomes**

- Understand benefits of using a pipeline approach like {targets}
- How to write functions that work in a pipeline
- How to debug common pipeline issues
- How to use {targets} with {geotargets}

# Details

## Introduction to {targets} (9 hours)

Data analysis is an iterative process. Data cleaning, exploratory data analysis (EDA), and model fitting are rarely run without a hitch from start to finish. Each step takes time, and often requires revisiting earlier steps to correct for newly discovered problems. For example, in performing EDA, you can unearth a text issue that requires revisiting data cleaning. When you are finally done with the analysis, you will need to reproduce it to check it all works as expected.

To reproduce the analysis, there is a temptation to run the code again from the top, which may take a long time. You can save time by saving model outputs, but if you make a change to an earlier data cleaning step, you’ll need to update everything that depends on that. And sometimes it isn’t exactly clear which components depend on each other. If you’ve found yourself saying: “I’ll just run it all from scratch again”, you have likely experienced this.

You can write code to manage these dependencies, but this is a hard problem. Fortunately, “pipeline tools” are an existing approach to manage these dependencies. They take care of the details of watching which files and relevant code changes, and only run the necessary parts. The {targets} R package is one popular pipeline approach, providing extensive documentation and user support. However, it presents a different coding practice that might not be familiar.

In this course walkthrough, I will gently introduce the ideas behind {targets}, and by the end we will be able to live code a data analysis using {targets} from scratch, warts and all.

My goal is that you will be able to write modular functions suitable for pipelines, understand how {targets} tracks changes in data and code, and develop skills for debugging common pipeline issues. Through practical examples, participants will discover how adopting a pipeline approach prevents unnecessary re-computation and creates more maintainable, transparent workflows.

## Geospatial workflows with {geotargets} (3 hours)

Geospatial data presents a technical challenge for {targets}, as packages like {terra} create objects containing C++ pointers rather than actual data. This makes them incompatible with standard data storage (serialization) methods. The {geotargets} package solves these challenges by providing specialized target factories that handle these aspects automatically.

In this next section we will demonstrate how to integrate {geotargets} into {targets} workflows for both raster and vector data, using geospatial packages {terra} and {sf}.

Participants will learn to build efficient geospatial pipelines that can handle computationally intensive operations—which may take hours or days to complete—while avoiding re-running entire analyses when only specific components change, dramatically improving productivity in geospatial data science.

# Schedule

Eight chapters, ninety minutes each. The course is exercise heavy, so most of that time is yours rather than mine.

## 1. Why pipelines?

*90 minutes*

- Where do I start? What do I run first?
- Common problems with pipelines and workflows
- Working with occurrence records: reading, cleaning, mapping with {leaflet}
- Finding out that your answer was wrong, twice
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
