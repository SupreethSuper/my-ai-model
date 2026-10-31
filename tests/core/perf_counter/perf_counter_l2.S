#
# Copyright 2019 Jeff Bush
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#include "asm_macros.h"

#
# Smoke test for L2 performance events (indices follow the core events).
# Event 15 is L2 miss, 16 is L2 hit. Load from a line that has never been
# touched (miss), then store to it (hits in L2).
#

                    .text
                    .align 4

                    .globl _start
_start:             lea s5, read_loc
                    move s0, 15     # L2 miss event
                    setcr s0, CR_PERF_EVENT_SELECT0
                    move s0, 16     # L2 hit event
                    setcr s0, CR_PERF_EVENT_SELECT1
                    getcr s6, CR_PERF_EVENT_COUNT0_L
                    getcr s7, CR_PERF_EVENT_COUNT1_L

                    load_32 s0, (s5)    # L2 miss (line not in L2)
                    add_i s1, s0, 1     # Wait for load to complete
                    store_32 s0, (s5)   # L2 hit (line was filled by load)
                    membar

                    getcr s8, CR_PERF_EVENT_COUNT0_L
                    sub_i s8, s8, s6
                    getcr s9, CR_PERF_EVENT_COUNT1_L
                    sub_i s9, s9, s7

                    # Instruction fetches also generate L2 traffic, so only
                    # check that each event was observed at least once.
                    cmpgt_i s10, s8, 0
                    bnz s10, 1f
                    call fail_test
1:                  cmpgt_i s10, s9, 0
                    bnz s10, 1f
                    call fail_test
1:                  call pass_test

                    .align 64
read_loc:           .long 0
