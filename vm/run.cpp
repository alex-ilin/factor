#include "master.hpp"

namespace factor {

void factor_vm::primitive_exit() { exit((int)to_fixnum(ctx->pop())); }

void exit(int status) {
  close_console();
  ::exit(status);
}

void factor_vm::primitive_nano_count() {
  uint64_t nanos = nano_count();
  // Work around a VirtualBox bug: http://www.virtualbox.org/ticket/6318.
  while (nanos < last_nano_count)
    nanos = nano_count();
  last_nano_count = nanos;
  ctx->push(from_unsigned_8(nanos));
}

void factor_vm::primitive_sleep() { sleep_nanos(to_unsigned_8(ctx->pop())); }

}
