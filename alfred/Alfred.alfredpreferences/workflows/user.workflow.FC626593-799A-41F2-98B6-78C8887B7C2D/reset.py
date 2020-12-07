# encoding: utf-8
from workflow import Workflow


def main(wf):
    wf.reset()
    wf.delete_password('gitea_api_key')


if __name__ == u"__main__":
    wf = Workflow()
    log = wf.logger
    wf.run(main)
