#version 330 core

// Atributos de fragmentos recebidos como entrada ("in") pelo Fragment Shader.
// Neste exemplo, este atributo foi gerado pelo rasterizador como a
// interpolação da posição global e a normal de cada vértice, definidas em
// "shader_vertex.glsl" e "main.cpp".
in vec4 position_world;
in vec4 normal;

// Posição do vértice atual no sistema de coordenadas local do modelo.
in vec4 position_model;

// Coordenadas de textura obtidas do arquivo OBJ (se existirem!)
in vec2 texcoords;

// Matrizes computadas no código C++ e enviadas para a GPU
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

// Identificador que define qual objeto está sendo desenhado no momento
#define SPHERE 0
#define BUNNY 1
#define PLANE  2
#define COW 3
#define VEADO 4
#define PATO 5
#define CUBE 6
#define SKYDOME 7
#define CILINDER 8
#define LEVER 9
#define XWALL 10
#define ZWALL 11
#define CONDOR 12
#define BUNNY_FRAME 13
#define COW_FRAME 14
#define DEER_FRAME 15
#define DUCK_FRAME 16


uniform int object_id;

// Parâmetros da axis-aligned bounding box (AABB) do modelo
uniform vec4 bbox_min;
uniform vec4 bbox_max;

// Variáveis para acesso das imagens de textura
uniform sampler2D TextureImage0;
uniform sampler2D TextureImage1;
uniform sampler2D TextureImage2;
uniform sampler2D TextureImage3;
uniform sampler2D TextureImage4;
uniform sampler2D TextureImage5;
uniform sampler2D TextureImage6;
uniform sampler2D TextureImage7;
uniform sampler2D TextureImage8;
uniform sampler2D TextureImage9;
uniform sampler2D TextureImage10;
uniform sampler2D TextureImage11;
uniform sampler2D TextureImage12;





// O valor de saída ("out") de um Fragment Shader é a cor final do fragmento.
out vec3 color;

// Constantes
#define M_PI   3.14159265358979323846
#define M_PI_2 1.57079632679489661923
#define EULER 2.71828


void main()
{
    // Obtemos a posição da câmera utilizando a inversa da matriz que define o
    // sistema de coordenadas da câmera.
    vec4 origin = vec4(0.0, 0.0, 0.0, 1.0);
    vec4 camera_position = inverse(view) * origin;
    vec4 camera_view_vector = vec4(view[0][2], view[1][2], view[2][2], 0.0);

    // O fragmento atual é coberto por um ponto que percente à superfície de um
    // dos objetos virtuais da cena. Este ponto, p, possui uma posição no
    // sistema de coordenadas global (World coordinates). Esta posição é obtida
    // através da interpolação, feita pelo rasterizador, da posição de cada
    // vértice.
    vec4 p = position_world;

    // Normal do fragmento atual, interpolada pelo rasterizador a partir das
    // normais de cada vértice.
    vec4 n = normalize(normal);


    // Vetor que define o sentido da fonte de luz em relação ao ponto atual.
    vec4 l = normalize(camera_position - p);

    // Vetor que define o sentido da câmera em relação ao ponto atual.
    vec4 v = normalize(camera_position - p);

    // Vetor que define o sentido da reflexão especular ideal.
    vec4 r = -l+2*n*dot(n,l); // PREENCHA AQUI o vetor de reflexão especular ideal

    //half-vector do modelo de iluminação blinn-phong
    vec4 h = normalize(v+l);

    // Coordenadas de textura U e V
    float U = 0.0;
    float V = 0.0;


    // Parâmetros que definem as propriedades espectrais da superfície
    vec3 Kd; // Refletância difusa
    vec3 Ks; // Refletância especular
    vec3 Ka; // Refletância ambiente
    float q; // Expoente especular para o modelo de iluminação de Phong

    if ( object_id == SKYDOME )
    {
        vec4 bbox_center = (bbox_min + bbox_max) / 2.0;

        vec4 p_ = bbox_center + ((position_model - bbox_center)/length(position_model - bbox_center));

        float theta = atan(p_.x,p_.z);
        float phi = asin(p_.y);

        U = (theta+M_PI) / (2*M_PI);
        V = (phi + (M_PI / 2)) / (M_PI);

        Kd = texture(TextureImage4, vec2(U,V)).rgb;
    }
    if ( object_id == XWALL )
    {
        U = texcoords.x*16;
        V = texcoords.y;

        Kd = texture(TextureImage7, vec2(U,V)).rgb;
    }
    if ( object_id == ZWALL )
    {
        U = texcoords.x;
        V = texcoords.y*16;

        Kd = texture(TextureImage7, vec2(U,V)).rgb;
    }

    else if ( object_id == BUNNY || object_id == VEADO || object_id == PATO || object_id == COW)
    {
        float rx = bbox_min.x;
        float qx = bbox_max.x;

        float ry = bbox_min.y;
        float qy = bbox_max.y;

        float rz = bbox_min.z;
        float qz = bbox_max.z;

        U = (position_model.x - rx) / (qx - rx);
        V = (position_model.y - ry) / (qy - ry);

        Kd = texture(TextureImage3, vec2(U,V)).rgb;

    }
    else if ( object_id == PLANE )
    {

        U = texcoords.x * 30;
        V = texcoords.y * 30;

        Kd = texture(TextureImage2, vec2(U,V)).rgb;

    }
    else if (object_id == CUBE)
    {
        float rx = bbox_min.x;
        float qx = bbox_max.x;

        float ry = bbox_min.y;
        float qy = bbox_max.y;

        float rz = bbox_min.z;
        float qz = bbox_max.z;

        U = ((position_model.x - rx) / (qx - rx)) * 4;
        V = ((position_model.z - rz) / (qz - rz)) * 4;

        Kd = texture(TextureImage1, vec2(U,V)).rgb;
        Ks = vec3(0.3,0.3,0.3);
        Ka = vec3(0.0,0.0,0.0);
        q = 20.0;
    }

    else if (object_id == CILINDER)
    {
        float rx = bbox_min.x;
        float qx = bbox_max.x;

        float ry = bbox_min.y;
        float qy = bbox_max.y;

        float rz = bbox_min.z;
        float qz = bbox_max.z;

        U = ((position_model.x - rx) / (qx - rx)) * 4;
        V = ((position_model.z - rz) / (qz - rz)) * 4;

        Kd = texture(TextureImage5, vec2(U,V)).rgb;
        Ks = vec3(0.3,0.3,0.3);
        Ka = vec3(0.0,0.0,0.0);
        q = 20.0;
    }

        else if (object_id == LEVER)
    {
        float rx = bbox_min.x;
        float qx = bbox_max.x;

        float ry = bbox_min.y;
        float qy = bbox_max.y;

        float rz = bbox_min.z;
        float qz = bbox_max.z;

        U = ((position_model.x - rx) / (qx - rx)) * 4;
        V = ((position_model.z - rz) / (qz - rz)) * 4;

        Kd = texture(TextureImage6, vec2(U,V)).rgb;
        Ks = vec3(0.3,0.3,0.3);
        Ka = vec3(0.0,0.0,0.0);
        q = 20.0;
    }
    else if (object_id == CONDOR)
    {
        float rx = bbox_min.x;
        float qx = bbox_max.x;

        float ry = bbox_min.y;
        float qy = bbox_max.y;

        float rz = bbox_min.z;
        float qz = bbox_max.z;

        U = ((position_model.x - rx) / (qx - rx)) * 4;
        V = ((position_model.z - rz) / (qz - rz)) * 4;

        Kd = texture(TextureImage6, vec2(U,V)).rgb;
        Ks = vec3(0.3,0.3,0.3);
        Ka = vec3(0.0,0.0,0.0);
        q = 20.0;
    }
    else if (object_id == BUNNY_FRAME)
    {
        U = texcoords.x ;
        V = texcoords.y ;

        Kd = texture(TextureImage9, vec2(U,V)).rgb;
    }
    else if (object_id == COW_FRAME)
    {
        U = texcoords.x;
        V = -texcoords.y;

        Kd = texture(TextureImage10, vec2(U,V)).rgb;
    }
    else if (object_id == DEER_FRAME)
    {
        U = texcoords.y;
        V = -texcoords.x;

        Kd = texture(TextureImage11, vec2(U,V)).rgb;
    }
    else if (object_id == DUCK_FRAME)
    {
        U = texcoords.y;
        V = texcoords.x;

        Kd = texture(TextureImage12, vec2(U,V)).rgb;
    }


    // Espectro da fonte de iluminação
    vec3 I = vec3(1.0,1.0,1.0); // PREENCH AQUI o espectro da fonte de luz

    // Espectro da luz ambiente
    vec3 Ia = vec3(0.2,0.2,0.2); // PREENCHA AQUI o espectro da luz ambiente

    // Termo difuso utilizando a lei dos cossenos de Lambert
    vec3 lambert_diffuse_term =  Kd*I*max(0,dot(n,l)); // PREENCHA AQUI o termo difuso de Lambert

    // Termo ambiente
    vec3 ambient_term = Ka*Ia; // PREENCHA AQUI o termo ambiente

    // Termo especular utilizando o modelo de iluminação de BLINN-Phong
    vec3 blinn_phong_specular_term  = Ks*I*pow((dot(n,h)),q);

    // Equação de Iluminação
    float lambert = max(0,dot(n,l));

    if ( object_id == SKYDOME )
    {
        color = Kd * lambert * 0.2;
    }

    else if(object_id == CUBE || object_id == LEVER || object_id == CILINDER)
    {
        if(dot(normalize(p-camera_position),normalize(-camera_view_vector))<cos(M_PI/6))
        {
            color = ambient_term;
        }
        else
        {
            color = (lambert_diffuse_term + ambient_term + blinn_phong_specular_term) / max(length(p-camera_position), 1);
        }
    }
    else if(dot(normalize(p-camera_position),normalize(-camera_view_vector))<cos(M_PI/6)){
            color = ambient_term;
    }
    else {
            color = Kd * (lambert + 0.01) / max(length(p-camera_position), 1);
    }


    // Cor final com correção gamma, considerando monitor sRGB.
    // Veja https://en.wikipedia.org/w/index.php?title=Gamma_correction&oldid=751281772#Windows.2C_Mac.2C_sRGB_and_TV.2Fvideo_standard_gammas
    color = pow(color, vec3(1.0,1.0,1.0)/2.2);
}
