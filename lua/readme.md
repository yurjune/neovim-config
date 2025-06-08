### Support undercurl in tmux session

1. Check for Smulx support:
    a. `infocmp -l -x | grep Smulx`
    b. If no output, you need to add support for Smulx in your terminal's terminfo.
2. Check your TERM variable
    a. `echo $TERM`
3. Generate a Terminfo File:
    a. `infocmp > /tmp/${TERM}.ti`
4. Open term info file:
    a. `nvim /tmp/${TERM}.ti`
5. add follwing line:
    a. `Smulx=\E[4:%p1%dm,`
6. Compile the term info file:
    a. `tic -x /tmp/${TERM}.ti`

- [ref](https://dev.to/anurag_pramanik/how-to-enable-undercurl-in-neovim-terminal-and-tmux-setup-guide-2ld7)
