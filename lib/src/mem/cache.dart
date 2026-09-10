/* license: https://mit-license.org
 * =============================================================================
 * The MIT License (MIT)
 *
 * Copyright (c) 2025 Albert Moky
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 * =============================================================================
 */


// -----------------------------------------------------------------------------
//  MemoryCache (Generic Cache Interface)
// -----------------------------------------------------------------------------

/// Generic in-memory cache interface with memory reduction capability.
///
/// Defines the core contract for key-value cache operations, plus a specialized
/// method to reduce memory usage (critical for mobile/resource-constrained environments).
///
/// Type Parameters:
/// [K] is the type of cache keys (must be hashable).
/// [V] is the type of cache values (can be nullable).
abstract interface class MemoryCache<K, V> {

  /// Retrieves a value from the cache by key.
  ///
  /// [key] is the cache key to look up (non-null).
  ///
  /// Returns the cached value (null if key not found or value is null).
  V? get(K key);

  /// Stores a value in the cache.
  ///
  /// [key] is the cache key to associate with the value (non-null).
  /// [value] is the value to cache (null = remove the key from cache).
  ///
  /// Returns the previous value associated with the key (null if none).
  V? put(K key, V? value);

  /// Returns the current number of entries in the cache.
  ///
  /// Returns a non-negative integer representing the count of
  /// cached key-value pairs.
  int size();

  /// Reduces cache memory usage by evicting entries (implementation-specific logic).
  ///
  /// Returns the number of entries remaining in the cache after reduction.
  int reduceMemory();

}


// -----------------------------------------------------------------------------
//  ThanosCache (Half-Life Cache Implementation)
// -----------------------------------------------------------------------------

/// Implementation of [MemoryCache] with "Thanos-style" memory reduction.
///
/// Core feature: The [reduceMemory] method removes **exactly half** of the cache entries
/// (inspired by Thanos snapping his fingers to kill half the universe), making it
/// a deterministic eviction policy for memory optimization.
///
/// [K] is the type of cache keys (must be hashable).
/// [V] is the type of cache values (can be nullable).
///
/// Note: uses a standard [Map] as the underlying storage,
/// with O(1) get/put operations.
class ThanosCache<K, V> implements MemoryCache<K, V> {

  final Map<K, V> _caches = {};

  @override
  V? get(K key) => _caches[key];

  @override
  V? put(K key, V? value) {
    if (value == null) {
      // null value = remove key from cache
      return _caches.remove(key);
    }
    V? old = _caches[key];
    _caches[key] = value;
    return old;
  }

  @override
  int size() => _caches.length;

  @override
  int reduceMemory() {
    int finger = 0;
    // Execute Thanos-style eviction (kill half the entries)
    finger = thanos(_caches, finger);
    // Return number of remaining entries (half of original count)
    return finger >> 1;
  }

}


// -----------------------------------------------------------------------------
//  Thanos Eviction Logic (Helper Function)
// -----------------------------------------------------------------------------

/// Thanos-style cache eviction function - removes half of the map entries.
///
/// "Thanos can kill half lives of a world with a snap of the finger"
///
/// Eviction logic:
/// - iterates through map entries in insertion order;
/// - removes entries where the incremented finger counter is odd
///   (keeps even entries);
/// - guarantees exactly 50% of entries are removed (deterministic eviction).
///
/// [planet] is the map (cache) to "snap" (modify in-place).
/// [finger] is the starting counter value (typically 0 for fresh snap).
///
/// Returns the final value of the finger counter (total number of
/// entries processed).
///
/// Note: modifies the input map directly (in-place operation).
int thanos(Map planet, int finger) {
  // if ++finger is odd, remove it,
  // else, let it go
  planet.removeWhere((key, value) => (++finger & 1) == 1);
  return finger;
}
