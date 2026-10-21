"""Home Manager's native-link seam; all validation/ownership lives in dot.py."""
import sys
from pathlib import Path
from dot import Invalid, read_json, mappings, status, link_configs, stale_links

try:
    mode, options_file = sys.argv[1:]
    options = read_json(Path(options_file))
    home = Path(options['home'])
    links = mappings(Path(options['checkout']), read_json(Path(options['manifest'])),
                     home, Path(options['config']), options['selected'])
    conflicts = [str(t) for _, s, t in links if status(t, s) == 'conflict']
    if conflicts:
        raise Invalid('Foreign files/links preserved: ' + ', '.join(conflicts))
    if mode == 'check':
        stale_links(home, links)
    elif mode == 'apply':
        link_configs(home, links, backup=False)
    else:
        raise Invalid('Expected check or apply')
except (Invalid, OSError, ValueError, KeyError, TypeError, RuntimeError) as exc:
    sys.exit(f'dotfiles: {exc}')
