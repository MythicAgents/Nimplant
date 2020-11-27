proc debugMsg*(things: varargs[string, `$`]) {.inline.} =
    when defined(debug):
        for thing in things:
            echo thing