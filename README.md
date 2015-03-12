# gimme
A micro meta package manager for the masses.


## What. Does. __That__. MEAN?
The `gimme` command is intended to run micro scripts that get stuff (or get
stuff done). Ideally, it can do anything ~~that can be automated in shell~~.

Think of it as glue between tiny little tasks that are easy to define.


## No really... what does it do?
It deals with the shell scripts so that the engineers don't have to.


## Umm.. okay... how, then?


### install it (you do read these scripts, right?)
```bash
curl -fsSL "http://git.kylepdavis.com/kylepdavis/gimme/raw/master/gimme" | bash -
```

### use it
```bash
gimme goodies
# if it exists, it will run the "$GIMME_DIR/gimmes/goodies" script
# otherwise, it will run the "$GIMME_DIR/gimmes/_default" script (which by default installs stuff with your package manager)
```

### shell integration
You can get tab completion in bash by doing something like this (put it in your `.profile` to play for keeps):
```bash
source "$GIMME_DIR/gimme"
```


## What is in it for me?
The idea here is that the what you use this for is really up to you.

Here are some ideas for overall uses to get you started:
* install tools to compliment your `dotfiles` (that's one way that I'm using it)
* manage configurations for multiple machines (just make a new `config` "gimme" script that runs `gimme $HOST/install` and you're on your way to being able to run `gimme config`)
* collaborate with a team on commands for dev, ops, support, etc. (e.g., `gimme dev`, `gimme qa`, `gimme test_data`, `gimme auth/new_user`, etc.)

If that wasn't enough here are some ideas for the "gimmes":


## How do I write gimmes?
Simple:
1. write a shell script that does something awesome
  * helpers like `has` and `gimme_pkg` get inherited from the main `gimme` script if you want
  * add a check to make sure that it does nothing on subsequent runs -- idempotence is sexy
  * you can depend on other "gimmes" by simply calling `gimme that other thing` at the top
2. put it into the `$GIMME_DIR/gimmes/` directory
3. make it executable with something like `chmod 755 YOUR_GIMME_SCRIPT`


## What else?
Also, it prevents cycles so one of your "gimmes" could

What you use this for could range from a small set of personal tools that you use to compliment your dotfiles
rdotconfiguration management suite to compliment your dotfiles to a
 getting stuff.
You can take that to mean whatever you want. Use my defaults or fork this project and add your own scripts.


## What makes it better than X?
Maybe nothing. Lots of things do dependency tracking. I wanted to try this out.

Some suggested using `Makefile` files but that felt a little clunky. Plus `make` isn't exactly installed everywhere.
Neither is `bash` but it was good enough for me.

You could technically use something like chef, puppet, ansible, salt, etc. but those felt *way* too heavy for my needs.

Just trying to keep it simple and shell scripts are about as simple as it gets.

Here's another project that somewhat agrees:
 [https://github.com/brandonhilkert/fucking_shell_scripts](fucking_shell_scripts) project

