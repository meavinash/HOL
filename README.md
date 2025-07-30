# Logic Visualizer

A comprehensive Elixir project for parsing, analyzing, and visualizing logical expressions using the HOL (Higher Order Logic) library.

## Overview

The Logic Visualizer provides a complete toolkit for working with logical expressions, including:

- **Expression Parsing**: Parse complex logical expressions with support for propositional logic, quantifiers, lambda calculus, and type annotations
- **HOL Integration**: Convert parsed expressions to HOL terms for formal manipulation and analysis
- **Tree Visualization**: Generate visual representations of expression structure and logical decomposition
- **Step-by-Step Processing**: Analyze expressions through detailed processing stages with explanations
- **CLI Interface**: Command-line tool for interactive and batch processing of logical expressions
- **Type System**: Comprehensive type inference and checking for logical expressions

## Features

### Supported Expression Types

- **Propositional Logic**: ¬, ∧, ∨, →, ↔
- **Quantifiers**: ∀, ∃, ∃!
- **Lambda Calculus**: λ abstractions, function application, composition
- **Type Annotations**: :o, :i, and custom types
- **Equality**: = operator
- **Special Operators**: ⇒, ⇔, ∘

### Visualization Capabilities

- **Expression Trees**: Hierarchical representation of expression structure
- **Decomposition Trees**: Step-by-step logical decomposition analysis
- **Natural Deduction**: Proof tree visualization
- **Truth Tables**: Complete truth table analysis for propositional expressions
- **Step-by-Step Processing**: Detailed analysis with explanations at each stage

### Analysis Features

- **Type Inference**: Automatic type determination for all expression components
- **Semantic Analysis**: Meaning interpretation and property identification
- **Pattern Recognition**: Detection of tautologies, contradictions, and logical patterns
- **Complexity Analysis**: Expression complexity and depth calculations
- **HOL Conversion**: Seamless integration with HOL library for formal reasoning

## Installation

### Prerequisites

- Elixir 1.15 or later
- Erlang/OTP 25 or later

### Dependencies

The project depends on the following packages:

- `hol` - Higher Order Logic library
- `nimble_parsec` - Parser combinator library
- `ex_doc` - Documentation generation (dev only)

### Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd logic_visualizer
```

2. Install dependencies:
```bash
mix deps.get
```

3. Run tests to verify installation:
```bash
mix test
```

## Usage

### Command Line Interface

The Logic Visualizer provides a comprehensive CLI tool:

#### Basic Usage

```bash
# Analyze a simple expression
logic_visualizer "A ∨ ¬A"

# Show expression tree
logic_visualizer -t "∀x:o. P x → P x"

# Show step-by-step processing
logic_visualizer -s "A → B"

# Show detailed analysis
logic_visualizer -D "λx. f x"
```

#### Advanced Usage

```bash
# Show all analysis types
logic_visualizer -t -s -d -l -y "A ∧ (A → B) → B"

# Process expressions from file
logic_visualizer -f expressions.txt

# Save results to file
logic_visualizer -o results.txt "∀x:i. ∃y:i. x + y = 0"

# Generate comprehensive report
logic_visualizer -D -p -r -o report.txt "∃!x. P(x)"
```

#### Interactive Mode

```bash
# Start interactive mode
logic_visualizer

# Or using the escript
./logic_visualizer interactive
```

### Programmatic Usage

#### Basic Analysis

```elixir
alias LogicVisualizer.Parser.ExpressionParser
alias LogicVisualizer.HOLIntegration.HOLConverter
alias LogicVisualizer.Visualization.TreeVisualizer

# Parse an expression
{:ok, parsed} = ExpressionParser.parse("A ∨ ¬A")

# Convert to HOL
{:ok, hol_term} = HOLConverter.convert(parsed)

# Generate visualization
{:ok, tree} = TreeVisualizer.visualize_expression_tree(parsed)
```

#### Full Analysis Pipeline

```elixir
alias LogicVisualizer.Processing.StepProcessor

# Process complete analysis
{:ok, steps} = StepProcessor.process_full_analysis("A ∨ ¬A")

# Each step contains detailed information
Enum.each(steps, fn step ->
  IO.puts("Step #{step.step}: #{step.phase}")
  IO.puts("Description: #{step.description}")
  IO.puts("Explanation: #{step.explanation}")
  IO.puts("---")
end)
```

#### Batch Processing

```elixir
alias LogicVisualizer.CLI

# Process multiple expressions
expressions = [
  "A ∨ ¬A",
  "∀x:o. P x → P x",
  "(A → B) → ((B → C) → (A → C))"
]

CLI.batch_mode(expressions, %{
  detailed: true,
  output: "batch_results.txt"
})
```

## Expression Examples

### Propositional Logic

```elixir
# Law of Excluded Middle
"A ∨ ¬A"

# Modus Ponens
"(A ∧ (A → B)) → B"

# De Morgan's Laws
"¬(P ∧ Q) ↔ (¬P ∨ ¬Q)"
"¬(P ∨ Q) ↔ (¬P ∧ ¬Q)"
```

### Quantified Logic

```elixir
# Universal Quantification
"∀x:o. P x → P x"

# Existential Quantification
"∃x:o. P x"

# Unique Existence
"∃!x. P(x)"

# Quantifier Duality
"(¬(∀x:o. P x)) → (∃x:o. ¬P x)"
```

### Lambda Calculus

```elixir
# Lambda Abstraction
"λx. f x"

# Function Composition
"(f ∘ g)(x) = f(g(x))"

# Beta Reduction
"(λx. f x) a"

# Identity Function
"λx:i. x"
```

### Type Theory

```elixir
# Typed Variables
"x:o"

# Typed Lambda
"λx:i. x"

# Polymorphic Identity
"λα. λx:α. x"
```

## Architecture

### Core Modules

#### Parser Module (`LogicVisualizer.Parser`)
- `ExpressionParser`: Main parser using NimbleParsec
- `Precedence`: Operator precedence management

#### HOL Integration (`LogicVisualizer.HOLIntegration`)
- `HOLConverter`: Converts parsed expressions to HOL terms
- `TypeManager`: Type inference and management

#### Visualization (`LogicVisualizer.Visualization`)
- `TreeVisualizer`: General tree visualization
- `LogicTree`: Specialized logic tree generation

#### Processing (`LogicVisualizer.Processing`)
- `StepProcessor`: Step-by-step analysis and processing

#### CLI (`LogicVisualizer.CLI`)
- `CLI`: Main CLI interface
- `Main`: Entry point and utilities

### Data Flow

```
Input Expression → Parser → Parsed AST → Type Inference → HOL Conversion
    ↓
Tree Visualization ← Step Processing ← Logical Analysis ← HOL Term
    ↓
CLI Output / File Output
```

## Testing

### Running Tests

```bash
# Run all tests
mix test

# Run specific test file
mix test test/logic_visualizer_test.exs

# Run with coverage
mix test --cover

# Run performance tests
mix test --only performance
```

### Test Coverage

The test suite covers:
- Expression parsing for all supported constructs
- Type inference and validation
- HOL conversion and manipulation
- Tree generation and visualization
- Step processing and analysis
- Error handling and edge cases
- Performance benchmarks

## Examples and Demos

### Example Expressions

The project includes a comprehensive set of example expressions:

```elixir
alias LogicVisualizer.Examples

# Get all examples
examples = Examples.get_all_examples()

# Get examples by category
propositional = Examples.get_by_category(:propositional_logic)
quantified = Examples.get_by_category(:quantified_logic)

# Get test examples
test_examples = Examples.get_test_examples()

# Generate test file
Examples.generate_test_file("my_examples.txt")
```

### Live Demo

```elixir
# Interactive analysis
alias LogicVisualizer.CLI
CLI.start_interactive()

# Quick analysis
CLI.Main.quick_analyze("A ∨ ¬A")

# Batch analysis
CLI.Main.batch_analyze([
  "A ∨ ¬A",
  "∀x:o. P x → P x",
  "(A → B) → ((B → C) → (A → C))"
])
```

## Configuration

### Environment Variables

- `LOGIC_VISUALIZER_OUTPUT_DIR`: Default output directory for generated files
- `LOGIC_VISUALIZER_MAX_DEPTH`: Maximum recursion depth for processing
- `LOGIC_VISUALIZER_DEBUG`: Enable debug logging

### Configuration File

Create a `config/config.exs` file:

```elixir
import Config

config :logic_visualizer,
  output_dir: "./output",
  max_depth: 100,
  debug: false,
  default_visualization: :tree
```

## Performance

### Benchmarks

The system is optimized for:
- Fast parsing of complex expressions
- Efficient type inference
- Scalable tree generation
- Memory-efficient processing

### Performance Tips

- Use batch processing for multiple expressions
- Limit recursion depth for very complex expressions
- Use file output for large results
- Enable debug mode for troubleshooting

## Contributing

### Development Setup

1. Fork the repository
2. Create a feature branch
3. Install dependencies: `mix deps.get`
4. Run tests: `mix test`
5. Make your changes
6. Add tests for new functionality
7. Ensure all tests pass
8. Submit a pull request

### Code Style

- Follow Elixir conventions
- Use meaningful variable and function names
- Add documentation to all public functions
- Include type specifications where appropriate
- Write comprehensive tests

### Adding New Features

1. Update the parser for new syntax
2. Add type inference rules
3. Implement HOL conversion
4. Add visualization support
5. Update CLI options
6. Add examples and tests
7. Update documentation

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Built on the HOL (Higher Order Logic) library
- Uses NimbleParsec for efficient parsing
- Inspired by formal logic and type theory research
- Thanks to the Elixir community for excellent tooling

## Support

For issues, questions, or contributions:
- GitHub Issues: [Project Issues]
- Documentation: [API Documentation]
- Examples: See `examples/` directory

---

**Logic Visualizer** - Making formal logic accessible and visual.