#include "shader.h"

using namespace std;

#ifndef M_PI
#define M_PI 3.141592654
#endif

using namespace glm;

GLint programObject_;
GLuint mvpLoc_;
GLuint mvLoc_;
GLuint lightLoc_;
GLuint upLoc_;
GLuint color_;
static const int VERTEX_POS_INDX = 0;
static const int VERTEX_NORMAL_INDX = 2;
static const int VERTEX_TEXCOORD_INDX = 1;

mat4 view_;
mat4 proj_;
vec3 light_;
vec3 up_;

static mat4x4 player(mat4x3::null);
float points[100][100];

struct Vertex {
    vec3 pos;
    vec3 normal;
    vec2 uv;
};

struct Cube {
    Cube();
    void draw();
    
    vector<Vertex> vertices;
    vector<ushort> indices;
    
    GLuint vbo;
    GLuint ibo;
};

Cube::Cube(){
    vertices.push_back(Vertex({vec3(.5,-.5,.5), vec3(), vec2()}));
    vertices.push_back(Vertex({vec3(.5,.5,.5), vec3(), vec2()}));
    vertices.push_back(Vertex({vec3(-.5,.5,.5), vec3(), vec2()}));
    vertices.push_back(Vertex({vec3(-.5,-.5,.5), vec3(), vec2()}));
    
    vertices.push_back(Vertex({vec3(.5,-.5,-.5), vec3(), vec2()}));
    vertices.push_back(Vertex({vec3(.5,.5,-.5), vec3(), vec2()}));
    vertices.push_back(Vertex({vec3(-.5,.5,-.5), vec3(), vec2()}));
    vertices.push_back(Vertex({vec3(-.5,-.5,-.5), vec3(), vec2()}));
    
    
    indices.push_back(0);
    indices.push_back(1);
    indices.push_back(2);
    
    indices.push_back(2);
    indices.push_back(3);
    indices.push_back(1);
    
    
    indices.push_back(5);
    indices.push_back(4);
    indices.push_back(7);
    
    indices.push_back(7);
    indices.push_back(6);
    indices.push_back(5);
    
    
    indices.push_back(0);
    indices.push_back(5);
    indices.push_back(1);
    
    indices.push_back(4);
    indices.push_back(5);
    indices.push_back(0);
    
    
    indices.push_back(7);
    indices.push_back(3);
    indices.push_back(2);
    
    indices.push_back(2);
    indices.push_back(3);
    indices.push_back(5);
    
    
    indices.push_back(4);
    indices.push_back(0);
    indices.push_back(3);
    
    indices.push_back(4);
    indices.push_back(7);
    indices.push_back(3);
    
    
    indices.push_back(6);
    indices.push_back(2);
    indices.push_back(1);
    
    indices.push_back(6);
    indices.push_back(5);
    indices.push_back(1);
    
    const int VERTEX_POS_SIZE = 3;
    const int VERTEX_NORMAL_SIZE = 3;
    const int VERTEX_TEXCOORD_SIZE = 2;
    
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, vertices.size()*sizeof(Vertex), &vertices[0], GL_STATIC_DRAW);
    
    glGenBuffers(1, &ibo);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.size()*sizeof(unsigned short), &indices[0], GL_STATIC_DRAW);
    
    glEnableVertexAttribArray ( VERTEX_POS_INDX );
    glEnableVertexAttribArray ( VERTEX_NORMAL_INDX );
    glEnableVertexAttribArray ( VERTEX_TEXCOORD_INDX );
    
    int offset = 0;
    Vertex *p = 0;
    
    glVertexAttribPointer ( VERTEX_POS_INDX, VERTEX_POS_SIZE, GL_FLOAT, GL_FALSE, sizeof(Vertex), &p->pos );
    offset += sizeof(vec3);
    
    glVertexAttribPointer ( VERTEX_NORMAL_INDX, VERTEX_NORMAL_SIZE, GL_FLOAT, GL_FALSE, sizeof(Vertex), &p->normal );
    offset += sizeof(vec3);
    
    glVertexAttribPointer ( VERTEX_TEXCOORD_INDX, VERTEX_TEXCOORD_SIZE, GL_FLOAT, GL_FALSE, sizeof(Vertex), &p->uv );
    offset += sizeof(vec2);
}

void Cube::draw() {
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
    
    glEnableVertexAttribArray ( VERTEX_POS_INDX );
    glEnableVertexAttribArray ( VERTEX_NORMAL_INDX );
    glEnableVertexAttribArray ( VERTEX_TEXCOORD_INDX );
    
    glDrawElements(GL_TRIANGLES, (int)indices.size(), GL_UNSIGNED_SHORT, 0);
}

Cube *pCube_;

/* OpenGL draw function & timing */
static void draw(void)
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // camera setup
    vec3 eye = vec3(0, 0, 5);
    mat4 rotate = glm::rotate<float>(mat4(), glfwGetTime() * 10, vec3(0,1,0));
    vec4 eye4 = rotate * vec4(eye, 1);
    eye = vec3(eye4);
    
    view_ = lookAt(eye, vec3(0,0,0), vec3(0,1,0));
    
    vec4 up4 = view_ * vec4(up_, 0);
    vec4 light4 = view_ * vec4(light_, 0);
    
    glUniform3fv(lightLoc_, 1, value_ptr(light4));
    glUniform3fv(upLoc_, 1, value_ptr(up4));
    
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);
    
    glFrontFace(GL_CCW);
    glCullFace(GL_BACK);
    
//    glPolygonMode( GL_FRONT_AND_BACK, GL_LINE );
    
    // draw cubes
//    float scale = .1;
    
    int const N = 30;
    float const space = 3;
    for(int i = 0; i < N; i++){
        for(int j = 0; j < N; j++){
            for(int k = 0; k < N; k++){
                float x = (float)i / (N-1);
                float y = (float)j / (N-1);
                float z = (float)k / (N-1);
                
                float scale = 0;
                float dd = x*x + y*y + z*z;
                dd *= (sin(glfwGetTime()*M_PI/2)+1)/2;
                if(abs(dd - 1) < .1){
                    scale = 1;
                }
                
                mat4 model = glm::translate(mat4(), space * vec3(i, j, k));
                model = glm::translate(model, -(N-1)/2.f*space*vec3(1, 1, 1));
                model = glm::scale(mat4(), vec3(.05,.05,.05)*scale) * model;
                mat4 modelview = view_ * model;
                mat4 mvp = proj_ * modelview;
                glUniformMatrix4fv(mvLoc_, 1, GL_FALSE, value_ptr(modelview));
                glUniformMatrix4fv(mvpLoc_, 1, GL_FALSE, value_ptr(mvp));
                glUniform3f(color_,0, 0, 1);
                
                pCube_->draw();
            }
        }
    }
}

/* update animation parameters */
static void animate(void)
{
}


/* change view angle, exit upon ESC */
void key( GLFWwindow* window, int k, int s, int action, int mods )
{
    if( action != GLFW_PRESS ) return;
    
    switch (k) {
        case GLFW_KEY_ESCAPE:
            glfwSetWindowShouldClose(window, GL_TRUE);
            break;

        case GLFW_KEY_Z:
            break;
            
        default:
            return;
    }
}


/* new window size */
void reshape( GLFWwindow* window, int width, int height )
{
    proj_ = glm::perspective<float>(60.f, (float) width / height, .1f, 100.f);
    glViewport(0, 0, width, height);
}


/* program & OpenGL initialization */
static void init(int argc, char *argv[])
{
    glClearColor(1, 1, 1, 1);

    GLuint vertexShader;
    GLuint fragmentShader;
    GLint linked;
    
    NSString *vertPath = [[NSBundle mainBundle] pathForResource:@"vertex" ofType:@"vsh"];
    NSString *fragPath = [[NSBundle mainBundle] pathForResource:@"fragment" ofType:@"fsh"];
    vertexShader = compileShaderFromFile (GL_VERTEX_SHADER, vertPath.UTF8String);
    fragmentShader = compileShaderFromFile (GL_FRAGMENT_SHADER, fragPath.UTF8String);
    
    programObject_ = glCreateProgram ( );
    
    assert ( programObject_ );
    
    glAttachShader ( programObject_, vertexShader );
    glAttachShader ( programObject_, fragmentShader );
    
    glBindAttribLocation ( programObject_, VERTEX_POS_INDX, "a_position" );
    glBindAttribLocation ( programObject_, VERTEX_NORMAL_INDX, "a_normal" );
    glBindAttribLocation ( programObject_, VERTEX_TEXCOORD_INDX, "a_coord" );
    
    glLinkProgram ( programObject_ );
    
    glGetProgramiv ( programObject_, GL_LINK_STATUS, &linked );
    
    assert(linked);
    
    glUseProgram ( programObject_ );
    
    mvpLoc_ = glGetUniformLocation( programObject_, "u_mvp" );
    mvLoc_ = glGetUniformLocation( programObject_, "u_mv" );
    upLoc_ = glGetUniformLocation( programObject_, "u_up" );
    lightLoc_ = glGetUniformLocation( programObject_, "u_light" );
    color_ = glGetUniformLocation( programObject_, "u_color");
    
    light_.z = -1;
    light_.x = -1;
    up_.y = 1;

    pCube_ = new Cube();
}


/* program entry */
int main(int argc, char *argv[])
{
    GLFWwindow* window;
    int width, height;
    
    if( !glfwInit() )
    {
        fprintf( stderr, "Failed to initialize GLFW\n" );
        exit( EXIT_FAILURE );
    }
    
    glfwWindowHint(GLFW_DEPTH_BITS, 16);
    
    int monitorCount;
    
    GLFWmonitor *primMonitor = glfwGetPrimaryMonitor();
    GLFWvidmode const * vidModes = glfwGetVideoModes(primMonitor, &monitorCount);
    GLFWvidmode const & vidMode = vidModes[monitorCount-1];
    
    window = glfwCreateWindow( vidMode.width, vidMode.height, "Gears", glfwGetPrimaryMonitor(), NULL );
    if (!window)
    {
        fprintf( stderr, "Failed to open GLFW window\n" );
        glfwTerminate();
        exit( EXIT_FAILURE );
    }
    
    
    // Set callback functions
    glfwSetFramebufferSizeCallback(window, reshape);
    glfwSetKeyCallback(window, key);
    
    glfwMakeContextCurrent(window);
    glfwSwapInterval( 1 );
    
    player = glm::translate(mat4(1), vec3(0,0,20));
    
    glfwGetFramebufferSize(window, &width, &height);
    reshape(window, width, height);
    
    // Parse command-line options
    init(argc, argv);
    
    // Main loop
    while( !glfwWindowShouldClose(window) )
    {
        // Draw gears
        draw();
        
        // Update animation
        animate();
        
        // Swap buffers
        glfwSwapBuffers(window);
        glfwPollEvents();
    }
    
    // Terminate GLFW
    glfwTerminate();
    
    // Exit program
    exit( EXIT_SUCCESS );
}
