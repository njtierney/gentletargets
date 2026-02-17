# Introduction to `targets` and `geotargets`


<!-- README.md is generated from README.qmd. Please edit that file -->

<!-- badges: start -->

<!-- badges: end -->

# Prerequisites

- Experience writing basic R scripts
- Familiarity with writing functions in R
- Experience with spatial data packages (terra, sf) helpful but not
  required
- Experience in writing your own data analysis

# Learning outcomes

- Understand benefits of using a pipeline approach like {targets}
- How to write functions that work in a pipeline
- How to debug common pipeline issues
- How to use {targets} with {geotargets}

# Course website

<https://gentle-targets.njtierney.com>

# Details

## Introduction to {targets} (9 hours)

Data analysis is an iterative process. Data cleaning, exploratory data
analysis (EDA), and model fitting are rarely run without a hitch from
start to finish. Each step takes time, and often requires revisiting
earlier steps to correct for newly discovered problems. For example, in
performing EDA, you can unearth a text issue that requires revisiting
data cleaning. When you are finally done with the analysis, you will
need to reproduce it to check it all works as expected.

To reproduce the analysis, there is a temptation to run the code again
from the top, which may take a long time. You can save time by saving
model outputs, but if you make a change to an earlier data cleaning
step, you’ll need to update everything that depends on that. And
sometimes it isn’t exactly clear which components depend on each other.
If you’ve found yourself saying: “I’ll just run it all from scratch
again”, you have likely experienced this.

You can write code to manage these dependencies, but this is a hard
problem. Fortunately, “pipeline tools” are an existing approach to
manage these dependencies. They take care of the details of watching
which files and relevant code changes, and only run the necessary parts.
The {targets} R package is one popular pipeline approach, providing
extensive documentation and user support. However, it presents a
different coding practice that might not be familiar.

In this course walkthrough, I will gently introduce the ideas behind
{targets}, and by the end we will be able to live code a data analysis
using {targets} from scratch, warts and all.

My goal is that you will be able to write modular functions suitable for
pipelines, understand how {targets} tracks changes in data and code, and
develop skills for debugging common pipeline issues. Through practical
examples, participants will discover how adopting a pipeline approach
prevents unnecessary re-computation and creates more maintainable,
transparent workflows.

## Geospatial workflows with {geotargets} (3 hours)

Geospatial data presents a technical challenge for {targets}, as
packages like {terra} create objects containing C++ pointers rather than
actual data. This makes them incompatible with standard data storage
(serialization) methods. The {geotargets} package solves these
challenges by providing specialized target factories that handle these
aspects automatically.

In this next section we will demonstrate how to integrate {geotargets}
into {targets} workflows for both raster and vector data, using
geospatial packages {terra} and {sf}.

Participants will learn to build efficient geospatial pipelines that can
handle computationally intensive operations—which may take hours or days
to complete—while avoiding re-running entire analyses when only specific
components change, dramatically improving productivity in geospatial
data science.

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
