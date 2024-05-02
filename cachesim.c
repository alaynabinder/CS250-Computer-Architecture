
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char memory[1 << 24];

int log2(int n) {
    int r = 0;
    while (n >>= 1) r++;
    return r;
}

struct block {
    int valid;
    int dirty;
    int tag;
    char data[1024];
    int lru;
};

int main(int argc, char* argv[]) {
    // ./cachesim <trace-file> <cache-size-kB> <associativity> <block-size>
    // ./cachesim traces/example.txt 1024 4 32
    FILE* file = fopen(argv[1], "r");
    int cache_size = atoi(argv[2]) * 1024; // 1 KB = 1024 bytes in CS 250
    int num_ways = atoi(argv[3]);
    int block_size = atoi(argv[4]);

    // Calculations for cache
    int num_sets = cache_size / block_size / num_ways;
    int offset_bits = log2(block_size);
    int index_bits = log2(num_sets);
    int tag_bits = 24 - offset_bits - index_bits;
    int index_mask = (1 << index_bits) - 1;
    int offset_mask = (1 << offset_bits) - 1;

    // Cache = 2D array
    struct block** cache = (struct block**)malloc(num_sets * sizeof(struct block*));
    for (int i = 0; i < num_sets; i++) {
        cache[i] = (struct block*)malloc(num_ways * sizeof(struct block));
        for (int j = 0; j < num_ways; j++) {
            cache[i][j].valid = 0;
            cache[i][j].dirty = 0;
            cache[i][j].tag = 0;
            memset(cache[i][j].data, 0, sizeof(cache[i][j].data));
            cache[i][j].lru = 0;
        }
    }

    // For LRU
    int global_clock = 0;

    // Initialize
    char type[8]; 
    int address;
    int access_size;
    char data[block_size];

    while (fscanf(file, "%s 0x%x %d", type, &address, &access_size) != EOF) {
        int tag = address >> (offset_bits + index_bits);
        int index = (address >> offset_bits) & index_mask;
        int block_offset = address & offset_mask;
        
        int hit = 0;
        int hit_idx = 0;

        // Locate cache block to use
        for (int j = 0; j < num_ways; j++) {
            if (cache[index][j].tag == tag && cache[index][j].valid) {
                hit = 1;
                hit_idx = j; 
                break;
            }
        }

        // For LRU
        global_clock++;
        int replace = 0;
        int replace_idx = hit_idx;
        int min_time = 1 << 24; // Arbitrarily large number

        // Checking if eviction is needed
        if (!hit) {
            int empty = 0;
            for (int j = 0; j < num_ways; j++) {
                if (cache[index][j].valid == 0) {
                    empty = 1;
                    replace_idx = j;
                    break;
                }
            }
            if (empty == 0) replace = 1;
        }

        // LOAD
        if (strcmp(type, "load") == 0) {
            // HIT
            if (hit == 1) {
                // Return data
                printf("%s 0x%x hit ", type, address);
                for (int i = 0; i < access_size; i++) {
                    printf("%02hhx", cache[index][replace_idx].data[block_offset + i]);
                }
                printf("\n");
                cache[index][replace_idx].lru = global_clock;
            }
            
            // MISS
            else {
                // Evict
                if (replace == 1) {
                    for (int j = 0; j < num_ways; j++) {
                        if (cache[index][j].lru < min_time) {
                            min_time = cache[index][j].lru;
                            replace_idx = j;
                        }
                    }
                    int evict_addr = ((cache[index][replace_idx].tag << index_bits) + index) << offset_bits;
                    if (cache[index][replace_idx].dirty == 1) { // Address of the first byte within the block being evicted
                        printf("replacement 0x%x dirty\n", evict_addr);

                        // Write previous dirty data (evicted cache block) back to lower memory
                        for (int i = 0; i < block_size; i++) { 
                            memory[evict_addr + i] = cache[index][replace_idx].data[i];
                        }
                    } else {
                        printf("replacement 0x%x clean\n", evict_addr);
                        
                    }
                }
                cache[index][replace_idx].lru = global_clock;

                // --------------------------------------------------

                int block_addr = address - block_offset;

                // Read data from lower memory into cache block
                for (int i = 0; i < block_size; i++) { 
                    cache[index][replace_idx].data[i] = memory[block_addr + i];
                }

                // Mark the cache block as not dirty, valid, and update tag
                cache[index][replace_idx].dirty = 0;
                cache[index][replace_idx].tag = tag;
                cache[index][replace_idx].valid = 1;
                
                // Return data
                printf("%s 0x%x miss ", type, address); 
                for (int i = 0; i < access_size; i++) {
                    printf("%02hhx", cache[index][replace_idx].data[block_offset + i]);
                }
                printf("\n");
            }
        }

        // STORE
        if (strcmp(type, "store") == 0) {
            // Read data value to be written, store in data array
            for (int i = 0; i < access_size; i++) {
                fscanf(file, "%2hhx", &data[i]);
            }

            // HIT
            if (hit == 1) {
                printf("%s 0x%x hit\n", type, address);

                // Write new data into cache block
                for (int i = 0; i < access_size; i++) { 
                    cache[index][hit_idx].data[block_offset + i] = data[i];
                }
                cache[index][hit_idx].lru = global_clock;
            }

            // MISS
            else {
                // Evict
                if (replace == 1) {
                    for (int j = 0; j < num_ways; j++) {
                        if (cache[index][j].lru < min_time) {
                            min_time = cache[index][j].lru;
                            replace_idx = j;
                        }
                    }
                    int evict_addr = ((cache[index][replace_idx].tag << index_bits) + index) << offset_bits;
                    if (cache[index][replace_idx].dirty == 1) { // Address of the first byte within the block being evicted
                        printf("replacement 0x%x dirty\n", evict_addr);

                        // Write previous dirty data (evicted cache block) back to lower memory
                        for (int i = 0; i < block_size; i++) { 
                            memory[evict_addr + i] = cache[index][replace_idx].data[i];
                        }
                    } else {
                        printf("replacement 0x%x clean\n", evict_addr);
                    }
                }
                cache[index][replace_idx].lru = global_clock;

                // --------------------------------------------------

                printf("%s 0x%x miss\n", type, address); 

                int block_addr = address - block_offset;

                // Read data from lower memory into cache block
                for (int i = 0; i < block_size; i++) { 
                    cache[index][replace_idx].data[i] = memory[block_addr + i];
                }

                // Write new data into cache block
                for (int i = 0; i < access_size; i++) { 
                    cache[index][replace_idx].data[block_offset + i] = data[i];
                }
            }
            // Mark the cache block as dirty, valid, and update tag
            cache[index][replace_idx].dirty = 1;
            cache[index][replace_idx].tag = tag;
            cache[index][replace_idx].valid = 1;
        }
    }
    for (int i = 0; i < num_sets; i++) free(cache[i]);
    free(cache);

    fclose(file);
    return EXIT_SUCCESS;
}