/**
 * In-Memory Data Store for Local Development
 * 
 * Replaces Firebase Firestore with a simple in-memory store so the backend
 * works immediately without any Firebase credentials or emulator setup.
 * 
 * Data persists only while the server is running. Restart = fresh start.
 */

class InMemoryCollection {
  constructor(name) {
    this.name = name;
    this.data = new Map();
  }

  doc(id) {
    const self = this;
    return {
      async get() {
        const docData = self.data.get(id);
        return {
          exists: !!docData,
          id: id,
          data: () => docData ? { ...docData } : undefined,
        };
      },
      async set(data, options = {}) {
        if (options.merge && self.data.has(id)) {
          const existing = self.data.get(id);
          self.data.set(id, { ...existing, ...data });
        } else {
          self.data.set(id, { ...data });
        }
      },
      async update(data) {
        const existing = self.data.get(id);
        if (!existing) throw new Error(`Document ${id} not found in ${self.name}`);
        self.data.set(id, { ...existing, ...data });
      },
      async delete() {
        self.data.delete(id);
      },
    };
  }

  where(field, op, value) {
    return new InMemoryQuery(this, [{ field, op, value }]);
  }
}

class InMemoryQuery {
  constructor(collection, filters = [], ordering = null, limitCount = null) {
    this.collection = collection;
    this.filters = filters;
    this.ordering = ordering;
    this.limitCount = limitCount;
  }

  where(field, op, value) {
    return new InMemoryQuery(
      this.collection,
      [...this.filters, { field, op, value }],
      this.ordering,
      this.limitCount
    );
  }

  orderBy(field, direction = 'asc') {
    return new InMemoryQuery(
      this.collection,
      this.filters,
      { field, direction },
      this.limitCount
    );
  }

  limit(count) {
    return new InMemoryQuery(
      this.collection,
      this.filters,
      this.ordering,
      count
    );
  }

  async get() {
    let results = [];

    for (const [id, data] of this.collection.data.entries()) {
      let match = true;
      for (const filter of this.filters) {
        const fieldValue = data[filter.field];
        switch (filter.op) {
          case '==':
            if (fieldValue !== filter.value) match = false;
            break;
          case '!=':
            if (fieldValue === filter.value) match = false;
            break;
          case '>':
            if (!(fieldValue > filter.value)) match = false;
            break;
          case '<':
            if (!(fieldValue < filter.value)) match = false;
            break;
          default:
            if (fieldValue !== filter.value) match = false;
        }
      }
      if (match) {
        results.push({
          id,
          exists: true,
          data: () => ({ ...data }),
        });
      }
    }

    // Sort
    if (this.ordering) {
      const { field, direction } = this.ordering;
      results.sort((a, b) => {
        const aVal = a.data()[field] || '';
        const bVal = b.data()[field] || '';
        const cmp = String(aVal).localeCompare(String(bVal));
        return direction === 'desc' ? -cmp : cmp;
      });
    }

    // Limit
    if (this.limitCount) {
      results = results.slice(0, this.limitCount);
    }

    return {
      empty: results.length === 0,
      docs: results,
      size: results.length,
      forEach: (fn) => results.forEach(fn),
    };
  }
}

class InMemoryBatch {
  constructor(store) {
    this.store = store;
    this.operations = [];
  }

  set(ref, data) {
    this.operations.push({ type: 'set', ref, data });
  }

  async commit() {
    for (const op of this.operations) {
      if (op.type === 'set') {
        await op.ref.set(op.data);
      }
    }
  }
}

class InMemoryFirestore {
  constructor() {
    this.collections = new Map();
    console.log('📦 Using in-memory data store (no Firebase required)');
  }

  collection(name) {
    if (!this.collections.has(name)) {
      this.collections.set(name, new InMemoryCollection(name));
    }
    return this.collections.get(name);
  }

  batch() {
    return new InMemoryBatch(this);
  }
}

const db = new InMemoryFirestore();

module.exports = { db };
