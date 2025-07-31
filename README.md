# Logic Visualizer

Logic Visualizer is a comprehensive Elixir tool for parsing and visualizing logical expressions. It integrates parsing, Higher Order Logic (HOL) representation, and visualization, making it a valuable resource for those interested in logic and computation.

## Table of Contents
- [Overview](#overview)
- [Installation](#installation)
- [Usage](#usage)
- [Features](#features)
- [Testing](#testing)
- [Contributing](#contributing)
- [License](#license)

## Overview
The application provides comprehensive capabilities for working with logical expressions. These include parsing expressions, converting them into HOL for formal reasoning, and generating visualizations of expression trees.

## Installation
To use the Logic Visualizer, install it locally by cloning the repository:

```bash
git clone https://github.com/meavinash/HOL.git
```

Then, navigate into the directory:

```bash
cd HOL
mix deps.get
```

## Usage
Run the CLI with example expressions:

```bash
mix run
```

To use Logic Visualizer in interactive mode, run:

```bash
mix escript.build
./logic_visualizer -i
```

## Features
- **Expression Parsing**: Supports propositional logic, quantified logic, and lambda calculus.
- **HOL Conversion**: Converts parsed expressions into HOL formats.
- **Visualizations**: Generates text-based visualization of logical structures.
- **Proofs and Analysis**: Employs a semantic tableaux prover to evaluate logical validity.
- **Examples**: Includes various logical and mathematical example expressions.

## Testing
To run tests, execute:

```bash
mix test
```

## Contributing
Contributions are welcome! For major changes, please open an issue first to discuss what you would like to change.

## License
This project is licensed under the MIT License. See the LICENSE file for details.

Logic Visualizer

A comprehensive Elixir project for parsing, analyzing, and visualizing logical expressions using the HOL (Higher Order Logic) library.

Overview

The Logic Visualizer provides a complete toolkit for working with logical expressions, including:

•  Expression Parsing: Parse complex logical expressions with support for propositional logic, quantifiers, lambda calculus, and type annotations
•  HOL Integration: Convert parsed expressions to HOL terms for formal manipulation and analysis
•  Tree Visualization: Generate visual representations of expression structure and logical decomposition
•  Step-by-Step Processing: Analyze expressions through detailed processing stages with explanations
•  CLI Interface: Command-line tool for interactive and batch processing of logical expressions
•  Type System: Comprehensive type inference and checking for logical expressions

Features

Supported Expression Types

•  Propositional Logic
•  Quantifiers
•  Lambda Calculus
•  Type Annotations
•  Equality
•  Special Operators

Visualization Capabilities

•  Expression Trees
•  Decomposition Trees
•  Natural Deduction
•  Truth Tables
•  Step-by-Step Processing

Analysis Features

•  Type Inference
•  Semantic Analysis
•  Pattern Recognition
•  Complexity Analysis
•  HOL Conversion