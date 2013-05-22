#
# Default environment setting for development build
#
# usage:
#   cd atos-build
#   . ./setenv.sh
#

deactivate() {
  # Restore old values
  PATH="$_OLD_ATOS_PATH" && export PATH
  unset _OLD_ATOS_PATH

  unset PYTHONPATH && [ "${_OLD_ATOS_PYTHONPATH+set}" = set ] && PYTHONPATH="$_OLD_ATOS_PYTHONPATH" && export PYTHONPATH
  unset _OLD_ATOS_PYTHONPATH

  unset PYTHONSTARTUP && [ "${_OLD_ATOS_PYTHONSTARTUP+set}" = set ] && PYTHONSTARTUP="$_OLD_ATOS_PYTHONSTARTUP" && export PYTHONSTARTUP
  unset _OLD_ATOS_PYTHONSTARTUP

  unset PS1 && [ "${_OLD_ATOS_PS1+set}" = set ] && PS1="$_OLD_ATOS_PS1" && export PS1
  unset _OLD_ATOS_PS1

  # Make bash and zsh forget about previous commands
  # Overwise the last PATH change will not be taken into account
  if [ -n "$BASH" -o -n "$ZSH_VERSION" ] ; then
    hash -r
  fi

  unset ATOS_BUILD_SETENV

  # Self destroy
  unset -f deactivate
}

if [ -n "$ATOS_BUILD_SETENV" ]; then
  echo "error: already in ATOS environment. Execute 'deactivate' to get out." >&2
else
  echo
  echo "Setting up ATOS environment. Execute 'deactivate' to get out."
  echo

  ATOS_BUILD_SETENV=1

  # Save old values
  _OLD_ATOS_PATH="$PATH"
  unset _OLD_ATOS_PYTHONPATH && [ "${PYTHONPATH+set}" = set ] && _OLD_ATOS_PYTHONPATH="$PYTHONPATH"
  unset _OLD_ATOS_PYTHONSTARTUP && [ "${PYTHONSTARTUP+set}" = set ] && _OLD_ATOS_PYTHONSTARTUP="$PYTHONSTARTUP"
  unset _OLD_ATOS_PS1 && [ "${PS1+set}" = set ] && _OLD_ATOS_PS1="$PS1"

  # Export the new ones
  PATH=$PWD/devimage/bin:$PATH && export PATH
  PYTHONPATH=$PWD/devimage/lib/python:$PYTHONPATH && export PYTHONPATH
  unset PYTHONSTARTUP
  PS1="(atos-build) $PS1" && export PS1

  # Makes bash and zsh to forget about previous command and take PATH change into
  # account
  if [ -n "$BASH" -o -n "$ZSH_VERSION" ] ; then
    hash -r
  fi
fi
