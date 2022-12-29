# vod archive

To use the scripts in `tasks` which fetch data from Vimeo, first create a file
in the root of the project named `env.sh` with the following contents

```sh
#!/bin/bash
client_id='<secret>'
client_secret='<secret>'
access_token='<secret>'
```

Replace `<secret>` with the appropriate values and mark the file as executable.
