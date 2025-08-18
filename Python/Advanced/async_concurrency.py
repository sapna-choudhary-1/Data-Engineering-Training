"""
threading – for multitas_keying with I/O (like file or API calls)

multiprocessing – for CPU-intensive parallelism

asyncio – for async I/O like network/API calls

"""

print("""\n------------------------------------------------------------------------------
------------------------------------------------------------------------------
-------------------------------- THREADING - (for I/O-bound concurrency) ---------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------""")
import threading
import time

def tas_key(name):
    print(f"Starting {name}")
    time.sleep(2)  # Simulate I/O
    print(f"Finished {name}")

threads = []
for i in range(3):
    t = threading.Thread(target=tas_key, args=(f"Thread-{i}",))
    t.start()
    threads.append(t)

for t in threads:
    t.join()


print("""\n------------------------------------------------------------------------------
------------------------------------------------------------------------------
-------------------------------- MULTIPROCESSING - (for CPU-bound parallelism) ---------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------""")
import multiprocessing
import math

def calc_square(n):
    print(f"Calculating square of {n}")
    return n * n

if __name__ == "__main__":
    with multiprocessing.Pool(processes=4) as pool:
        results = pool.map(calc_square, [1, 2, 3, 4])
    print(results)


print("""\n------------------------------------------------------------------------------
------------------------------------------------------------------------------
-------------------------------- ASYNCIO - (for highly scalable async I/O) ---------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------""")
import asyncio

async def fetch_data(site):
    print(f"Fetching from {site}")
    await asyncio.sleep(1)  # Simulate network I/O
    print(f"Done with {site}")

async def main():
    tas_keys = [fetch_data(f"site{i}") for i in range(5)]
    await asyncio.gather(*tas_keys)

asyncio.run(main())