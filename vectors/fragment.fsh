uniform vec3 u_color;
uniform vec3 u_up;
uniform vec3 u_light;

varying vec3 v_position;
varying vec3 v_normal;
varying vec2 v_coord;

void main()
{
    vec2 coord = v_coord;
    vec3 normal = v_normal;
    
//    coord.x = mod(v_coord.x * 5.0, 1.0);
//    coord.y = mod(v_coord.y * 5.0, 1.0);
    
    gl_FragColor = vec4 (
        u_color.r,
        u_color.g,
        u_color.b,
        1.0 );
}
