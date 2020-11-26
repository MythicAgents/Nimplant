template debugMsg*(things: varargs[string, `$`]) =
    when defined(debug):
        for thing in things:
            echo thing