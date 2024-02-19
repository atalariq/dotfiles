# This is Fucking README

## Convert `rc.xml` to `rc.yaml` and Vice-Versa
Requirements:
- [dasel](https://github.com/TomWright/dasel)

```bash
# xml -> yaml
dasel -r xml -w yaml -f rc.xml > rc.yaml

# yaml -> xml
dasel select -f rc.yml -r yaml '.' -w xml > rc.xml
```
