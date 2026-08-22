// agent — generic base class for the class-based testbench.
//
// Concrete agents (driver, checker, ...) extend this class to inherit
// the `notify` notification hook.  The actual signup queue is held at
// module scope (a fixed-size array + head/tail counters) and accessed
// via module-level tasks `signup_put / signup_get / signup_num`.  This
// is a workaround for Icarus Verilog 13, which doesn't yet support
// queues of class handles or method calls on class member fields.
//
// Conceptually the signup queue still belongs to the agent layer:
// only classes that extend `agent` are intended to put/get on it.

class agent;

    // Notification hook: fires when the agent participates in a
    // queue event (sign-up by a driver, removal by a checker, ...).
    // Default is a silent no-op; override in derived classes.
    virtual task notify(softmax_msg msg);
    endtask

endclass
