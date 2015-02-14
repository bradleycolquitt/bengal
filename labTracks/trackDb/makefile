# Make your private trackDb with 
#	make update
# Your private trackDb with additional options, for example:
#       make EXTRA="-strict -settings" update
# Make it for genome-test with
#	make alpha
# Make your private trackDb on local host (if defined as localDB.XXX=XXX in .hg.conf) with
#	make updateLocal  
# Make non-private trackDb on local host (if defined as localDB.XXX=XXX in .hg.conf) with
#	make alphaLocal  
# Make for ENCODE reporting (includes release alpha and release beta)
#	make encodeReport

# Browser supports multiple trackDb's so that individual developers
# can change things rapidly without stepping on other people's toes. 
# Usually when updating it is best to update your own trackDb and
# test it to make sure it works and that you have git updated all
# of trackDb/ before doing a make alpha. Note that you
# must specify which trackDb you are using in your .hg.conf file
# or in the cgi-bin-$(USER)/hg.conf file. Something like: 
# db.trackDb=trackDb_YourUserName

# note:  new group ARCHIVED_DBS created for assemblies still needed
# to support Conservation tracks in other assemblies.  These should
# have only chromInfo table on hgwbeta and RR.  make will not rebuild
# trackDb on hgwdev unless the db is specified explicitly on the 
# command line.

include ../inc/common.mk

DBS = 	hg19 \
	galGal4 \
	taeGut2 \
        lonStrDom1 lonStrDom2 \


GSID_DBS = \
	hiv1 vax004 hivgne8 hivmn hivmn1 hivmn2 hivgne8v2 hivVax003Vax004

ARCHIVED_DBS = \
	rheMac1 \
	danRer1 \
	mm5 \
	mm6 \
	danRer2

# if trix build breaks, disable by setting to /bin/true instead of ./buildTrix
# BUILD_TRIX = /bin/true
BUILD_TRIX = ./buildTrix
HIVE_TRIX = /hive/data/inside/trix
DATA_TRIX = /data/trix
ALPHA_MACHINE = bengal.cin.ucsf.edu
BETA_MACHINE = qateam@hgwbeta.cse.ucsc.edu

EXTRA = -sqlDir=${KENTHOME}/src/hg/lib

update: #clean
	./loadTracks ${EXTRA} trackDb_lab hgFindSpec_lab ${DBS}
	./checkMetaDb alpha metaDb_lab ${DBS}
	${MKDIR} ${CGI_BIN}-lab/encode
# no more cv.ra copy 2014-10-21
# 	rm -f ${CGI_BIN}-${USER}/encode/cv.ra
#	cp -p cv/alpha/cv.ra  ${CGI_BIN}-${USER}/encode
#  if you want to test track search tool with your own trix file
#	rm -f ${DBS:%=${HIVE_TRIX}/%_trackDb_${USER}.{ixx,ix}}
#	HGDB_TRACKDB=trackDb_${USER} ${BUILD_TRIX} trackDb_${USER} metaDb_${USER} ${CGI_BIN}-${USER}/encode/cv.ra ${ALPHA_MACHINE} ${HIVE_TRIX} ${DBS}
# you'll also need to set browser.trixPath to point to your trix file
# see kent/src/product/ex.hg/conf for details

alpha: clean
	${GIT} pull
	./loadTracks ${EXTRA} -release=alpha trackDb hgFindSpec ${DBS}
	./checkMetaDb alpha metaDb ${DBS}
	${MKDIR} ${CGI_BIN}/encode
#	rm -f ${CGI_BIN}/encode/cv.ra
#	cp -p cv/alpha/cv.ra ${CGI_BIN}/encode
	rm -f ${DBS:%=${HIVE_TRIX}/%_trackDb.{ixx,ix}}
	HGDB_TRACKDB=trackDb ${BUILD_TRIX} trackDb metaDb cv/alpha/cv.ra ${ALPHA_MACHINE} ${HIVE_TRIX} ${DBS}
	./makeTrixLinks trackDb ${HIVE_TRIX} ${DBS}

onbeta:	/cluster/home/${USER}/.hg.conf.beta

beta: onbeta clean 
	${GIT} pull
	# first make files for hgwdev-beta (we share the tables with hgwbeta)
#	rsync -a cv/beta/cv.ra ${CGI_BIN}-beta/encode/cv.ra
	HGDB_CONF=/cluster/home/${USER}/.hg.conf.beta HGDB_TRACKDB=trackDb ${BUILD_TRIX} trackDb metaDb cv/beta/cv.ra ${ALPHA_MACHINE} ${HIVE_TRIX} ${DBS}
	# now do loads on hgwbeta
	HGDB_CONF=/cluster/home/${USER}/.hg.conf.beta ./loadTracks ${EXTRA} -strict -release=beta trackDb hgFindSpec ${DBS}
	HGDB_CONF=/cluster/home/${USER}/.hg.conf.beta ./checkMetaDb beta metaDb ${DBS}
#	rsync -a cv/beta/cv.ra ${BETA_MACHINE}:${CGI_BIN}/encode/cv.ra
	HGDB_CONF=/cluster/home/${USER}/.hg.conf.beta HGDB_TRACKDB=trackDb ${BUILD_TRIX} trackDb metaDb cv/beta/cv.ra ${BETA_MACHINE} ${DATA_TRIX} ${DBS}

public: onbeta clean
	${GIT} pull
	HGDB_CONF=/cluster/home/${USER}/.hg.conf.beta ./loadTracks ${EXTRA} -strict -release=public trackDb_public hgFindSpec_public ${DBS}
	HGDB_CONF=/cluster/home/${USER}/.hg.conf.beta ./checkMetaDb public metaDb_public ${DBS}
	HGDB_CONF=/cluster/home/${USER}/.hg.conf.beta HGDB_TRACKDB=trackDb_public ${BUILD_TRIX} trackDb_public metaDb_public cv/public/cv.ra ${BETA_MACHINE} ${DATA_TRIX} ${DBS}

# this will fail if we are not in a beta checkout:
checkbeta:
	${GIT} branch | egrep '^[*] v[0-9]+_branch' > /dev/null

# not sure if anyone actually uses the target below. It used to be "beta".
buildBeta: checkbeta clean strict

encodeReport:
	${GIT} pull
	./loadTracks ${EXTRA} trackDb_encodeReport hgFindSpec ${DBS}

listDbs:
	@echo "# databases listed in trackDb/makefile DBS variable, with table counts"
	@for D in ${DBS}; do \
	    C=`hgsql -N -e "show tables;" $${D} 2> /dev/null | wc -l`; \
	    if [ "$${C}" -gt 0 ]; then \
		echo -e "$${D}\t$${C}"; \
	    fi \
	done

# Get rid of symbolic links (created by lower-level makefiles):
clean:
	find . -type l -exec rm {} \;

