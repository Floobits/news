---
date: '2014-06-05 13:50:05'
layout: post
slug: Coroutines and Asynchronous I/O
published: false
title: Coroutines and Asynchronous I/O
authors:
  - kansface
categories:
---

how to write a floobits
	event driven
		client/server can initiate events
		some requests require responses
		link to old articles

	what does event driven code look like?
		callbacks!
			flock of seagulls in node
				async
		callback hell in python

	no twisted because its too big??!

	we can do better
		python (no first class coroutines like in lua)
		defereds are a bit heavy handed, so just use callbacks

	reqs:
		python 6
		what happens with exceptions?

	build decorator

<pre>
def _unwind_generator(gen_expr, cb=None, res=None):
    try:
        while True:
            maybe_func = res
            args = []
            if type(res) == tuple:
                maybe_func = len(res) and res[0]

            if not callable(maybe_func):
                # send only accepts one argument... this is slightly dangerous if
                # we ever just return a tuple of one elemetn
                # TODO: catch no generator
                if type(res) == tuple and len(res) == 1:
                    res = gen_expr.send(res[0])
                else:
                    res = gen_expr.send(res)
                continue

            def f(*args):
                return _unwind_generator(gen_expr, cb, args)
            args = list(res)[1:]
            args.append(f)
            return maybe_func(*args)
        # TODO: probably shouldn't catch StopIteration to return since that can occur by accident...
    except StopIteration:
        pass
    except __StopUnwindingException as e:
        res = e.ret_val
    if cb:
        return cb(res)
    return res


class __StopUnwindingException(BaseException):
    def __init__(self, ret_val):
        self.ret_val = ret_val


def return_value(args):
    raise __StopUnwindingException(args)


def inlined_callbacks(f):
    """ Branching logic in async functions generates a callback nightmare.
    Use this decorator to inline the results.  If you yield a function, it must
    accept a callback as its final argument that it is responsible for firing.

    example usage:
    """
    @wraps(f)
    def wrap(*args, **kwargs):
        return _unwind_generator(f(*args, **kwargs))
    return wrap
</pre>



link to lua version
	https://github.com/kans/luvit-inlineCallbacks


