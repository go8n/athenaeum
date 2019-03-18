import os
import sys


sys.path.append(
    os.path.join(os.path.dirname(
        os.path.dirname(
            os.path.abspath(__file__)
        )
    ), 'athenaeum')
)
print('Directory appended to sys.path: ' + sys.path[-1])
