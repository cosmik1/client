# Cosmik Client

Cosmik Client is a component of the larger Cosmik project ecosystem. It serves as a modern and flexible task management tool developed as an alternative to Make. It allows you to organize commands and tasks through a clear YAML-based configuration, offering numerous advantages over traditional Make-based solutions.

## How It Works

Cosmik uses YAML files to define commands and subcommands. This structure enables intuitive task organization and makes it easily extensible. The core functionality is provided by a Bash script that processes and executes the YAML configurations.

## Installation

1. Copy the entire Cosmik Client directory structure into your project
2. Make sure the script is executable:
   ```bash
   chmod +x cosmik
   ```
3. To enable auto-completion, you need to source the script:
   ```bash
   source cosmik
   ```

This approach allows you to extend and customize the functionality specifically for your project's needs by adding your own YAML configuration files and modules.

## Basic Structure

Cosmik organizes commands in a two-level hierarchy:
- **Command** (defined in a YAML file)
    - **Subcommand** (defined within a command)

### YAML File Format

Each command file follows the format `cosmik_<command>.yaml` and has the following structure:

```yaml
description: Description of the command

variables:
  VARIABLE_NAME: value

targets:
  subcommand:
    description: Description of the subcommand
    parameters:
      - parameter1
      - parameter2
    variables:
      VARIABLE_NAME: value
    include:
      - dependency_module1
      - dependency_module2
    script: |
      # Bash script to execute the subcommand
```

## Usage

### Basic Commands

```bash
# Show help for all available commands
cosmik help

# Show help for a specific command
cosmik <command> help

# Execute a subcommand
cosmik <command> <subcommand> [--parameter1=value1] [--parameter2=value2]
```

### Auto-completion

Cosmik provides auto-completion for commands and subcommands after sourcing the script. You can use the Tab key to display available options.

## Dependency Management

Cosmik features a powerful include system for managing dependencies. The `include` function allows you to load modular script components into your targets:

```yaml
targets:
  example:
    include:
      - print
      - run
      - requirements
    script: |
      # Now you can use functions from the included modules
```

The system searches for include files in predefined directories and ensures that each module is loaded only once, even if it's requested multiple times. Dependencies are defined in the form of `source-*.sh` files that provide specific functionalities.

## Available Modules

Cosmik includes several predefined modules that can be used in scripts:

### print

The `print` module provides formatted output functions:

```bash
# Information message
print info "Info message"

# Progress message
print progress "Progress message..."
print progress-ok

# Success message
print success "Success message"

# Hint message
print hint "Hint message"

# Note message
print note "Note message"

# Warning message
print warn "Warning message"

# Error message
print error "Error message"

# Selection input
print select "Choose an option" --default="Option B" --hint="Select carefully" -- "Option A" "Option B" "Option C"

# Text input
print input "Enter your name" --default="User" --hint="Your full name"

# Command execution
print command "ls -la"
```

### run

The `run` module provides a way to execute commands and log their output:

```bash
# Execute a command and log the output
run echo "Hello World"
```

### requirements

The `requirements` module provides functions to check system requirements:

```bash
# Check if commands are available
test_command docker git kubectl

# Check version numbers
test_version kubectl "1.32.3" "$kubectl_version"

# Check hosts entries
test_hosts "foo.example.local" "bar.example.local"
```

## Logging

Cosmik provides integrated logging functions:

```bash
# Display the log
cosmik log show

# Display new log entries
cosmik log show_new

# Clear the log
cosmik log clear
```

For CI/CD pipelines or other automated environments, you can enable console logging by setting the `LOG_TO_CONSOLE` environment variable:

```bash
LOG_TO_CONSOLE=true cosmik <command> <subcommand>
```

This will output log messages to both the log file and the console, which is useful for monitoring progress in automated workflows.

## Extending

Cosmik can be extended with your own YAML files. To create a new command:

1. Create a YAML file named `cosmik_<command>.yaml`
2. Define the structure as described above
3. Place the file in the `client/targets/` directory

## Examples

### Example: Checking Requirements

```bash
cosmik requirements check
```

This command checks if all required tools are installed and have the correct versions.

### Example: Running an Interactive Script

```bash
cosmik test output
```

This script asks for a name, displays various output types, and demonstrates the use of the `print` functions.

## Advantages Over Make

- **Clear Structure**: YAML-based configuration with hierarchical organization
- **Integrated Help**: Automatic documentation of all commands
- **Unified Variable Environment**: Seamless integration of YAML-defined and shell variables
- **Shell-native Implementation**: No additional language to learn
- **Advanced Features**: Dependency management, parameter extraction, auto-completion
- **User-friendliness**: Consistent formatting of outputs

## Internal Working Principle

1. The main `cosmik` script loads the YAML files from the `client/targets/` directory
2. It processes the command arguments and extracts parameters
3. It loads required modules with the `include` function
4. It executes the script defined in the YAML

Cosmik Client thus provides a modern alternative for organizing development tasks and overcomes the limitations of Make in the area of task management.
