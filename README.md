# gimme
A meta micro manager for the masses.


## What. Does. _That_. MEAN?
The `gimme` command runs micro scripts that get small blocks of work done. These usually build on other tools and can be chained together. Ideally, it can do anything [that can be automated in shell].

It's like glue between tiny little tasks [like most shell scripts].


## No really... what does it do?
It deals with the shell scripts so that the engineers don't have to.

yeah... right...


## Installation
```bash
curl -fsSL "https://github.com/KylePDavis/gimme/raw/master/gimme" | bash -
```
_(you do read these shell scripts before just running them, right!?)_


## Usage
```bash
gimme THAT_THING_THAT_YOU_WANT
```


## Integration
You can get tab completion in bash by doing something like this (put it in your `.profile` to play for keeps):
```bash
source "$GIMME_DIR/gimme"
```


## Internals
```bash
# 1. try to run :
"$GIMME_DIR/gimmes/$THAT_THING_THAT_YOU_WANT"

# 2. if not, then run the nearest _default script, which should go and get things
"$GIMME_DIR/gimmes/_default"
```


## Customization
1. write a shell script that does something awesome
    * you can depend on other "gimmes" by simply calling `gimme that other thing` at the top
    * add a check to make sure that it does nothing on subsequent runs -- idempotence is sexy
    * helpers like `has` and `gimme_pkg` get inherited from the main `gimme` script if you want
2. put it into the `$GIMME_DIR/gimmes/` directory
3. make it executable with something like `chmod 755 YOUR_GIMME_SCRIPT`


## What is in it for me?
The idea here is that the what you use this for is really up to you.

Here are some ideas for overall uses to get you started:
* install tools to compliment your `dotfiles` (that's one way that I'm using it)
* manage configurations for multiple machines (just make a new `config` "gimme" script that runs `gimme $HOST/install` and you're on your way to being able to run `gimme config`)
* collaborate with a team on commands for dev, ops, support, etc. (e.g., `gimme dev`, `gimme qa`, `gimme test_data`, `gimme auth/new_user`, etc.)

If that wasn't enough here are some ideas for the "gimmes":


## What makes it better than X?
Maybe nothing. I thought it was a neat idea and wanted to try it out.
