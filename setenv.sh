#
# Default environment setting for development build
#
# usage:
#   cd atos-build
#   source setenv.sh
#   make all
#

deactivate() {
  # Restore old values
  if [ -n $"_OLD_ATOS_PATH" ]; then
    PATH="$_OLD_ATOS_PATH"
    export PATH
    unset _OLD_ATOS_PATH
  fi

  if [ -n $"_OLD_ATOS_PS1" ]; then
    PS1="$_OLD_ATOS_PS1"
    export PS1
    unset _OLD_ATOS_PS1
  fi

  if [ -n $"_OLD_ATOS_PYTHONPATH" ]; then
    PYTHONPATH="$_OLD_ATOS_PYTHONPATH"
    export PYTHONPATH
    unset _OLD_ATOS_PYTHONPATH
  fi

  # Make bash and zsh forget about previous commands
  # Overwise the last PATH change will not be taken into account
  if [ -n "$BASH" -o -n "$ZSH_VERSION" ] ; then
    hash -r
  fi

  # Self destroy
  unset -f deactivate
}


# Save old values
_OLD_ATOS_PATH="$PATH"
_OLD_ATOS_PYTHONPATH="$PYTHONPATH"
_OLD_ATOS_PS1="$PS1"

# Export the new ones
export PATH=$PWD/devimage/bin:$PATH
export PYTHONPATH=$PWD/devimage/lib/python:$PYTHONPATH
export PS1="(ATOS) $PS1"

# Makes bash and zsh to forget about previous command and take PATH change into
# account
if [ -n "$BASH" -o -n "$ZSH_VERSION" ] ; then
    hash -r
fi
