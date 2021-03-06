bandit-mayhem
=============

**Hey Nigel!**

## About
bandit-mayhem is a text-based game I am playing with in Ruby.

It's just a simple text-based RPG.  You play as Nigel, an Indiana Jones wannabe stuck in a world where the law of the land is kill or be killed.

You start out in a town called Lynwood that has been ravaged by Bandits.

Traverse through plains, towns and other areas collecting money, weapons and items. With no real goal in mind, you're bound to get bored.

![lynwood](http://i.imgur.com/L6gJYN6.png)
![shop](http://i.imgur.com/RRi1d6N.png)
![lynwood plains](http://i.imgur.com/u5mBn7C.png)
![battle](http://i.imgur.com/rwBDT46.png)

## How to Install

### OSX
```bash
$ git clone https://github.com/ddavison/bandit-mayhem.git
$ cd bandit-mayhem
$ brew install portaudio
$ brew install mpg123
$ bundle install
$ ruby game.rb
```

## How to play
Type `/help` in the console if you are lost.

Use `wasd` to move.  To move, type in the respective direction, `w - Up, s - Down, a - Left, d - Right` and press enter.

You can also chain moves.  For example, typing: `w w w w d` and pressing `ENTER` will go up four spaces, and right, one.
