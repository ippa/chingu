# Chingu

OpenGL accelerated 2D game framework for Ruby.
Builds on the awesome [Gosu](https://github.com/gosu/gosu) (Ruby/C++) which provides all the core functionality.
It adds simple yet powerful game states, pretty input handling, deployment safe asset-handling, a basic re-usable game object and automations of common task.

[Old readme](README.old.rdoc)

## Fork
This is a fork of the Chingu game framework, its purpose is to maintain it up
to-date with Gosu.

You can find the original repo of Chingu [here](https://github.com/ippa/chingu)

## Requirements

Ruby version higher that or equal to the required by Gosu itself, plus
Gosu's dependencies. As a rule of thumb, if you managed to install Gosu
then you're setup.

## Roadmap

I'd like to document the library with Yard instead of RDoc, also sort out all
the examples.

Along with maintenance, I'll develop some aspects of the library that are
lacking, in no special order, some of the flaws I've found:

- Style inconsistencies
- Somewhat poor naming
- Confusing code organization
- Outdated (library was made with Ruby Ruby 1.9.2(!) in mind)
- Some depedencies used by the library are, as of now, abandoned

## Development

Note that we use Rake for easy automation.

For building you need to do the next command in the root of the library
`rake build`
after that, there should be a `.gem` file under `dist/`.
