//
//  Door.m
//  splitview
//
//  Created by Ali Arslan on 14.06.15.
//  Copyright (c) 2015 Ming Li. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Door.h"
#import "HeadPosition.h"

@implementation Door{
    GLKVector4 worldViewCenter;
    float dotViewDir;
    float dotUpDir;
}

-(id)init:(NSString *)name Alignment :(BOOL)_zAligned{
    
    if(self = [super init:name Type:Door_]){
        self->openDoorDistLimit = 3.0;
        self->closed = true;
        self->partialOpen = false;
        self->zAligned = _zAligned;
        self->speed = 0.05;
    }
    return self;
}

-(void)calculateAttributes{
    
    [self calculateCenter];

    
    if (zAligned) {
        width = abs(self.maxZ) - abs(self.minZ);
    }else{
        width = abs(self.maxX) - abs(self.minX);
    }
    
    initialWorldCenter = GLKMatrix4MultiplyVector4([self initialModelMatrix], self->center);
    
    
}

-(float)distanceFromCamera{
    GLKMatrix4 modelView = [self getModelView:Left];
    worldViewCenter = GLKMatrix4MultiplyVector4(modelView, self->center);
    GLKVector4 cameraForward =GLKMatrix4MultiplyVector4([HeadPosition lView], GLKVector4Make(0, 0, 1, 0));
    GLKVector4 cameraUp =GLKMatrix4MultiplyVector4([HeadPosition lView], GLKVector4Make(0, 1, 0, 0));
    dotViewDir = GLKVector4DotProduct(cameraForward, self->center);
    dotUpDir = GLKVector4DotProduct(cameraUp, self->center);
    self->distanceFromCamera = fabsf(worldViewCenter.z);
    return self->distanceFromCamera;
}

-(void)changeStateIfRequired{
    if ((closed || partialOpen) && [self distanceFromCamera] < self->openDoorDistLimit  && dotViewDir>4 && dotUpDir>0.80) { //open
        GLKMatrix4 translationMatrix;
        if(self->zAligned){
            translationMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, self->speed);
        }else{
            translationMatrix = GLKMatrix4MakeTranslation(self->speed, 0.0f, 0.0f);
        }
        
        self.modelMatrix = GLKMatrix4Multiply(self.modelMatrix, translationMatrix);
        
        partialOpen = true;

        GLKVector4 worldCenter =  GLKMatrix4MultiplyVector4(self.modelMatrix, self->center);
        
        if (zAligned) {
            if((fabsf(worldCenter.z) - fabsf(initialWorldCenter.z))> width*1.9){
                closed = false;
                partialOpen = false;
            }
        }else{
            if((fabsf(worldCenter.x) - fabsf(initialWorldCenter.x))> width*1.9){
                closed = false;
                partialOpen = false;
            }
        
        }
        
        
    }else if ((!closed || partialOpen) && [self distanceFromCamera] > self->openDoorDistLimit){ //close
        GLKMatrix4 translationMatrix;
        if(self->zAligned){
            translationMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -self->speed);
        }else{
            translationMatrix = GLKMatrix4MakeTranslation(-self->speed, 0.0f, 0.0f);
        }
        
        self.modelMatrix = GLKMatrix4Multiply(self.modelMatrix, translationMatrix);
        
        partialOpen = true;
        GLKVector4 worldCenter =  GLKMatrix4MultiplyVector4(self.modelMatrix, self->center);

        if(zAligned){
            if((worldCenter.z - fabsf(initialWorldCenter.z))< 0){
                closed = true;
                partialOpen = false;
            }
        }else{
            if((worldCenter.x - fabsf(initialWorldCenter.x))< 0){
                closed = true;
                partialOpen = false;
            }
        
        }
        
        
    }
    
}
-(BOOL) isClosed{
    return closed;
}

@end