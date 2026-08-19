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
/// - [K] : Type of cache keys (must be hashable)
/// - [V] : Type of cache values (can be nullable)
abstract interface class MemoryCache<K, V> {

  /// Retrieves a value from the cache by key.
  ///
  /// Parameters:
  /// - [key] : Cache key to look up (non-null)
  ///
  /// Returns: Cached value (null if key not found or value is null)
  V? get(K key);

  /// Stores a value in the cache (or removes it if value is null).
  ///
  /// Parameters:
  /// - [key]   : Cache key to associate with the value (non-null)
  /// - [value] : Value to cache (null = remove the key from cache)
  void put(K key, V? value);

  /// Returns the current number of entries in the cache.
  ///
  /// Returns: Non-negative integer representing the count of cached key-value pairs
  int size();

  /// Reduces cache memory usage by evicting entries (implementation-specific logic).
  ///
  /// Returns: Number of entries remaining in the cache after reduction
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
/// Type Parameters:
/// - [K] : Type of cache keys (must be hashable)
/// - [V] : Type of cache values (can be nullable)
///
/// Note: Uses a standard [Map] as the underlying storage, with O(1) get/put operations.
class ThanosCache<K, V> implements MemoryCache<K, V> {

  final Map<K, V> _caches = {};

  @override
  V? get(K key) => _caches[key];

  @override
  void put(K key, V? value) => value == null
      ? _caches.remove(key)        // Null value = remove key from cache
      : _caches[key] = value;      // Non-null value = store/update entry

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
/// - Iterates through map entries in insertion order
/// - Removes entries where the incremented finger counter is odd (keeps even entries)
/// - Guarantees exactly 50% of entries are removed (deterministic eviction)
///
/// Parameters:
/// - [planet] : The map (cache) to "snap" (modify in-place)
/// - [finger] : Starting counter value (typically 0 for fresh snap)
///
/// Returns: Final value of the finger counter (total number of entries processed)
///
/// Note: Modifies the input map directly (in-place operation).
int thanos(Map planet, int finger) {
  // if ++finger is odd, remove it,
  // else, let it go
  planet.removeWhere((key, value) => (++finger & 1) == 1);
  return finger;
}
