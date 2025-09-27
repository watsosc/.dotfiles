if status is-interactive
    # Commands to run in interactive sessions can go here
end

starship init fish | source

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/sean/google-cloud-sdk/path.fish.inc' ]; . '/home/sean/google-cloud-sdk/path.fish.inc'; end
