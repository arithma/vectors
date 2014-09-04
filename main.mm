#include "shader.h"
#import <Foundation/Foundation.h>

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
const int VERTEX_POS_INDX = 0;
const int VERTEX_NORMAL_INDX = 2;
const int VERTEX_TEXCOORD_INDX = 1;

static mat4x4 player(mat4x3::null);
float points[100][100];

/* OpenGL draw function & timing */
static void draw(void)
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
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
    GLfloat h = (GLfloat) height / (GLfloat) width;
    GLfloat xmax, znear, zfar;
    
    znear = 5.0f;
    zfar  = 30.0f;
    xmax  = znear * 0.5f;
    
    glViewport( 0, 0, (GLint) width, (GLint) height );
    glMatrixMode( GL_PROJECTION );
    glLoadIdentity();
    glFrustum( -xmax, xmax, -xmax*h, xmax*h, znear, zfar );
}


/* program & OpenGL initialization */
static void init(int argc, char *argv[])
{
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
    
    window = glfwCreateWindow( vidMode.width/2, vidMode.height/2, "Gears", NULL, NULL );
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
