import json,os,signal,sys,time
from pathlib import Path
root=Path(sys.argv[1])
def stop(signum,frame):
 (root/'received-signal.json').write_text(json.dumps({'signal':signum,'name':signal.Signals(signum).name}))
 sys.exit(0)
for signum in (signal.SIGTERM,signal.SIGINT,signal.SIGHUP,signal.SIGPIPE): signal.signal(signum,stop)
(root/'ready.json').write_text(json.dumps({'pid':os.getpid(),'pgid':os.getpgrp()}))
time.sleep(40)
