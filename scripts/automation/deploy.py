import getopt
import piera
import sys


def main():
    config_path = ''
    environment = ''
    try:
        opts, _args = getopt.getopt(
            sys.argv[1:], "hc:e:", ["config_path=", "environment="]
        )

    except getopt.GetoptError as err:
        print(err)
        usage()
        sys.exit(2)

    for opt, arg in opts:
        if opt in ("-h", "--help"):
            usage()
            sys.exit()
        elif opt in ("-c", "--config_path"):
            config_path = arg
        elif opt in ("-e", "--environment"):
            environment = arg
        else:
            assert False, "unhandled option"

    h = piera.Hiera(config_path + "/hiera.yaml")
    print(h.get("foo", environment=environment))


def usage():
    print(sys.argv[0] + ' -i <inputfile> -o <outputfile>')


if __name__ == "__main__":
    main()
