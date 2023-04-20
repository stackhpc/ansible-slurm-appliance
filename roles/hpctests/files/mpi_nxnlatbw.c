/*
  Copyright (c) 2004,2005. PathScale, Inc. All rights reserved.
    
  Redistribution and use in source and binary forms, with or without 
  modification, are permitted provided that the following conditions
  are met:
    
  + All copies of source code must retain the above copyright notice, 
    this list of conditions and the following disclaimer. 

  + Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.

  + If user makes modifications to this software, and provides those 
    modifications to PathScale, user assigns to PathScale, Inc. ownership
    of the provided modifications and all intellectual property rights 
    embodied in those modifications. 
    
  + The name of PathScale, Inc. may not be used to endorse or promote 
    products derived from this software without specific prior written 
    permission. 
      
  THIS SOFTWARE IS PROVIDED BY PATHSCALE, INC. AND ITS LICENSORS "AS IS" 
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR 
  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL PATHSCALE, INC. OR ITS 
  LICENSORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR 
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
*/

/*
 * Derived from code supplied by Ohio State University:
 * Copyright (C) 2002-2003 the Network-Based Computing Laboratory
 * (NBCL), The Ohio State University.  
 *  http://nowlab.cis.ohio-state.edu/projects/mpi-iba/
 */

#include "mpi.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <unistd.h>

#define MYBUFSIZE 4*1024*1024
char s_buf[MYBUFSIZE];
char r_buf[MYBUFSIZE];

int main(int argc, char *argv[])
{

    int myid, numprocs, i;
    int size = MYBUFSIZE;
    MPI_Status stat;

    double t_start = 0.0, t_end = 0.0;
    int latloop = 10000, latskip = 10;
    int bwloop = 10, bwskip = 2;

    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);
    MPI_Comm_rank(MPI_COMM_WORLD, &myid);

    int src, dest;

    if (myid == 0 ) fprintf(stdout, "src,dst,lat(us),bandwidth((Mbytes/sec)\n");
    for (src = 0; src < numprocs; src++) {
        for (dest = 0; dest < numprocs; dest++) {
            if (src == dest)
                continue;
            MPI_Barrier(MPI_COMM_WORLD);

            if (myid == src) {
                for (i = 0; i < latloop + latskip; i++) {
                    if (i == latskip)
                        t_start = MPI_Wtime();
                    MPI_Send((void*)0, 0, MPI_CHAR, dest, 1, MPI_COMM_WORLD);
                    MPI_Recv((void*)0, 0, MPI_CHAR, dest, 1, MPI_COMM_WORLD,
                            &stat);
                }
                t_end = MPI_Wtime();

            } else if (myid == dest) {
                for (i = 0; i < latloop + latskip; i++) {
                    MPI_Recv((void*)0, 0, MPI_CHAR, src, 1, MPI_COMM_WORLD,
                            &stat);
                    MPI_Send((void*)0, 0, MPI_CHAR, src, 1, MPI_COMM_WORLD);
                }
            }

            if (myid == src) {
                double latency;
                latency = (t_end - t_start) * 1.0e6 / (2.0 * latloop);
                /*fprintf(stdout, "[%d<->%d]\t\t%0.2fus\t\t", src, dest, latency);*/
                fprintf(stdout, "%d,%d,%0.2f,", src, dest, latency);
            }

            /* touch the data */
            for ( i=0; i<size; i++ ){
                if(myid == src) {
                    s_buf[i]='a';
                    r_buf[i]='b';
                } else if (myid == dest) {
                    s_buf[i]='B';
                    r_buf[i]='A';
                }
            }

            MPI_Barrier(MPI_COMM_WORLD);
            if (myid == src) {
                for ( i=0; i< bwskip; i++ ) {
                    MPI_Send(s_buf, size, MPI_CHAR, dest, i, MPI_COMM_WORLD);
                }
                MPI_Recv(NULL, 0, MPI_CHAR, dest, i+1000, MPI_COMM_WORLD,&stat);
                t_start=MPI_Wtime();
                for ( i=0; i< bwloop; i++ ) {
                    MPI_Send(s_buf, size, MPI_CHAR, dest, i, MPI_COMM_WORLD);
                }
                MPI_Recv(NULL, 0, MPI_CHAR, dest, i+1000, MPI_COMM_WORLD,&stat);
                t_end=MPI_Wtime();
            } else if (myid == dest) {
                for ( i=0; i< bwskip; i++ ) {
                    MPI_Recv(r_buf, size, MPI_CHAR, src,i,MPI_COMM_WORLD,&stat);
                }
                MPI_Send(NULL, 0, MPI_CHAR, src, i + 1000, MPI_COMM_WORLD);
                for ( i=0; i< bwloop; i++ ) {
                    MPI_Recv(r_buf, size, MPI_CHAR, src,i,MPI_COMM_WORLD,&stat);
                }
                MPI_Send(NULL, 0, MPI_CHAR, src, i + 1000, MPI_COMM_WORLD);
            }

            if ( myid == src ) {
                double bw;
                bw = ((double)size*(double)bwloop)/((t_end-t_start)*(1.0e6));
                fprintf(stdout,"%f \n", bw);
            }
        }
        MPI_Barrier(MPI_COMM_WORLD);
    }

    MPI_Finalize();
    return 0;
}