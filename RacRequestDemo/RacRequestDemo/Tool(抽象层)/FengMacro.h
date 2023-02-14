//
//  FengMacro.h
//  RacRequestDemo
//
//  Created by frechai on 2021/7/1.
//  Copyright © 2021 Feng. All rights reserved.
//

#ifndef FengMacro_h
#define FengMacro_h

#define FengWeakify(object) __weak __typeof__(object) weak##_##object = object

#define FengStrongify(object) __typeof__(object) object = weak##_##object
#endif /* FengMacro_h */
