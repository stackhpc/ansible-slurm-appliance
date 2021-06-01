#!/usr/bin/python

# Copyright: (c) 2020, StackHPC
# Apache 2 License

def slurm_parse(output):
    """Parse sacct parsable output(i.e. using -p)

    :param output: a string containing the full output of sacct or
        an iterable yielding lines of sacct output
    :return List of dictionaries which map column headiings to values.
    """
    # Example input:
    # Cluster|ControlHost|ControlPort|RPC|Share|GrpJobs|GrpTRES|GrpSubmit|MaxJobs|MaxTRES|MaxSubmit|MaxWall|QOS|Def QOS|
    # testohpc|172.20.0.2|6817|8448|1||||||||normal||
    result = []
    if isinstance(output, str):
        output = output.splitlines()
    lines = iter(output)
    first_line = next(lines)
    if "|" not in first_line:
        raise ValueError("Could not parse headings")
    # Last value is empty due to trailing '|'
    headings = first_line.split("|")[:-1]
    for line in lines:
        record = {}
        # Last value is empty due to trailing '|'
        values = line.split("|")[:-1]
        for i, value in enumerate(values):
            record[headings[i]] = value
        result.append(record)
    return result

if __name__ == "__main__":
    slurm_parse_input = """Cluster|ControlHost|ControlPort|RPC|Share|GrpJobs|GrpTRES|GrpSubmit|MaxJobs|MaxTRES|MaxSubmit|MaxWall|QOS|Def QOS|
testohpc|172.20.0.2|6817|8448|1||||||||normal||"""
    slurm_parse_result = slurm_parse(slurm_parse_input)
    assert slurm_parse_result[0]["Cluster"] == "testohpc"
    assert "" not in slurm_parse_result
