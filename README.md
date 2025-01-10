# Self-Hosting Compiler Targeting x86 Assembly

## Overview

This project is a **self-hosting compiler** written in Racket that compiles a subset of a functional language into x86 assembly. The compiler supports a variety of language constructs, performs runtime integration for efficient memory and type handling, and includes an interpreter for testing and debugging. The project showcases a deep understanding of compiler design, language implementation, and systems programming.

Key features include:

- **Self-hosting capability**: The compiler can compile itself.
- **Support for a functional programming language**: Includes constructs such as pattern matching, closures, and tail-call optimization.
- **Target platform**: Generates x86 assembly compatible with Unix systems.
- **Runtime support**: Implements a runtime in C for memory management and I/O operations.
- **Comprehensive test suite**: Includes extensive tests for correctness and edge cases.

## Language Features

### **Supported Constructs**

The compiler supports the following language constructs:

- **Primitive types**:

  - Integers
  - Booleans (#t, #f)
  - Characters
  - Strings
  - Void
  - Empty lists ('())

- **Data structures**:

  - Lists
  - Boxed values
  - Vectors

- **Control flow**:

  - Conditionals (`if`)
  - Function definitions (`define`)
  - Function calls
  - Let-bindings (`let`)
  - Sequencing (`begin`)

- **Pattern matching**:

  - Match on literals, variables, lists, vectors, and custom predicates (`match` construct).

- **Arithmetic and comparison operations**:

  - Addition, subtraction
  - Equality, less-than comparison

- **I/O operations**:
  - Byte-level I/O with `read-byte`, `peek-byte`, and `write-byte`.

### **Compiler Features**

- **Tail-call optimization**: Ensures efficient recursion.
- **Memory management**: Implements a heap-based memory model in C.
- **Pattern matching**: Supports matching nested data structures with guards.
- **Error handling**: Graceful runtime error reporting.

## Project File Structure

### **Racket Files**

#### Compiler

- `compile.rkt`: The main compiler file that converts the abstract syntax tree (AST) into x86 assembly.
- `parse.rkt`: Parses the input source code into an AST.
- `compile-ops.rkt`: Defines operations for generating assembly instructions.
- `compile-stdin.rkt`: Reads source code from standard input, compiles it, and outputs assembly.
- `types.rkt`: Handles type representation and immediate values in the compiled program.

#### Interpreter

- `interp.rkt`: Implements the interpreter for executing the AST.
- `interp-prim.rkt`: Defines primitive operations for the interpreter.
- `interp-io.rkt`: Extends the interpreter to support I/O operations.
- `run.rkt`: Provides a function to execute compiled programs using an assembly interpreter.
- `run-stdin.rkt`: Reads source code from standard input, compiles it, and executes it using the runtime.

#### Testing

- `test/build-runtime.rkt`: Ensures the runtime object file is built before running tests.
- `test/compile.rkt`: Tests the compiler by compiling and running test cases.
- `test/interp.rkt`: Tests the interpreter on various programs.
- `test/test-runner.rkt`: Contains reusable test definitions and cases.

### **C Runtime**

- `runtime.h`: Defines the runtime interface for the compiled programs.
- `values.h` and `values.c`: Define and implement value representation and manipulation functions.
- `heap.h`: Defines the heap size and memory layout for runtime.
- `io.c`: Implements byte-level I/O operations.
- `main.c`: Entry point for executing compiled programs with runtime support.
- `print.c` and `print.h`: Provide functions for printing various types of values.
- `types.h`: Defines constants and masks for type checking and tagging.

### **Makefile**

- Automates the compilation of runtime files and the creation of the final executable.

## Prerequisites

- **Operating System**: Unix-based system (Linux or macOS).
- **Racket**: Required to run the compiler and interpreter.
- **GCC**: For compiling the runtime.
- **NASM**: Assembler for x86 assembly code.

## Installation

1. Install Racket:

   ```bash
   sudo apt install racket   # On Debian/Ubuntu
   brew install racket       # On macOS
   ```

2. Install GCC and NASM:

   ```bash
   sudo apt install gcc nasm  # On Debian/Ubuntu
   brew install nasm          # On macOS
   ```

3. Clone the repository:
   ```bash
   git clone https://github.com/nitvob/racket-compiler.git
   cd self-hosting-compiler
   ```

## Setup Instructions

1. Build the runtime:

   ```bash
   make
   ```

   This will generate `runtime.o` and other necessary object files.

2. Verify the setup:
   Run the test suite to ensure everything is working correctly:
   ```bash
   racket test/test-runner.rkt
   ```

## How to Run

### **Compile and Execute a Program**

1. Create a source file (e.g., `program.rkt`) with the following contents:

   ```racket
   (define (factorial n)
     (if (zero? n)
         1
         (* n (factorial (sub1 n)))))

   (factorial 5)
   ```

2. Compile the program:

   ```bash
   cat program.rkt | racket compile-stdin.rkt > program.s
   ```

3. Assemble and link the program:

   ```bash
   nasm -f elf64 program.s -o program.o
   gcc runtime.o program.o -o program
   ```

4. Run the program:
   ```bash
   ./program
   ```

### **Use the Interpreter**

To interpret the program directly without compilation:

```bash
racket interp-stdin.rkt < program.rkt
```

## Testing

To run the test suite:

```bash
racket test/test-runner.rkt
```

The test suite covers:

- Arithmetic operations.
- Pattern matching.
- Tail recursion.
- I/O operations.
- Compiler and interpreter correctness.

## Skills and Knowledge Gained

Through this project, I developed a strong expertise in **compiler design**, encompassing all aspects from parsing high-level constructs to generating efficient x86 assembly. I deepened my understanding of **systems programming**, including memory management, tagged data representation, and runtime integration, which allowed me to design a robust execution environment. This project also enhanced my **proficiency in Racket**, showcasing my ability to leverage functional programming for complex language implementations. Additionally, working with **x86 assembly and C** gave me valuable experience in low-level programming, enabling me to optimize performance and integrate runtime features seamlessly. Finally, I honed my **test-driven development skills** by building a comprehensive suite to ensure the correctness and robustness of the compiler and interpreter. This project exemplifies my ability to tackle challenging problems, design complex systems, and deliver reliable, high-performance solutions.
