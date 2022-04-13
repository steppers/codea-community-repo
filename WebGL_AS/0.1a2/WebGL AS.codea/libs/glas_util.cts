@global class Vec2i {
    x: i64;
    y: i64;

    constructor(x: i64 = 0, y: i64 = 0) {
        this.x = x;
        this.y = y;
    }
}

@global class Vec3i {
    x: i64;
    y: i64;
    z: i64;

    constructor(x: i64 = 0, y: i64 = 0, z: i64 = 0) {
        this.x = x;
        this.y = y;
        this.z = z;
    }
}

@global class Vec2f {
    x: f64;
    y: f64;

    constructor(x: f64 = 0, y:f64 = 0) {
        this.x = x;
        this.y = y;
    }
}

@global class Vec3f {
    x: f64;
    y: f64;
    z: f64;

    constructor(x: f64 = 0, y: f64 = 0, z: f64 = 0) {
        this.x = x;
        this.y = y;
        this.z = z;
    }
}